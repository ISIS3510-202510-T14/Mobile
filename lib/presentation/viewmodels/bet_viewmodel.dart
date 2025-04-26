// lib/presentation/viewmodels/bet_viewmodel.dart
// UPDATED – supports offline flag, writes isDraft, logs HTTP & sync errors

import 'dart:convert';
import 'package:campus_picks/src/config.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../data/models/bet_model.dart';
import '../../data/models/match_model.dart';
import '../../data/services/connectivity_service.dart';
import '../../data/repositories/bet_repository.dart';
import '../../data/repositories/error_log_repository.dart';
import '../../data/services/metrics_management.dart' as metrics_management;

class BetViewModel extends ChangeNotifier {
  final MatchModel match;
  final String userId;
  final ConnectivityNotifier connectivity;
  final BetRepository _repo = BetRepository();
  final ErrorLogRepository _errorRepo = ErrorLogRepository();
  late final double oddsA;
  late final double oddsB;

  /// Any UI‐facing message (e.g. SnackBar content)
  String? lastMessage;

  BetModel? _lastPlacedDraft;
  BetModel? get lastPlacedDraft => _lastPlacedDraft;

  BetViewModel({
    required this.match,
    required this.userId,
    required this.connectivity,
  }) {
    oddsA = match.oddsA;
    oddsB = match.oddsB;
  }

  /// Place a bet: online → POST & save; offline → save locally as draft.
  Future<void> placeBet(double amount, String team, bool offline) async {
    lastMessage = null;
    notifyListeners();

    if (!offline) {
      // ---------------- ONLINE ----------------
      final url = Uri.parse('${Config.apiBaseUrl}/api/bets');
      final odds = team == match.homeTeam ? oddsA : oddsB;
      final body = jsonEncode({
        "userId": userId,
        "eventId": match.acidEventId,
        "stake": amount,
        "odds": odds,
        "team": team,
      });

      final stopwatch = Stopwatch()..start();
      int? statusCode;
      bool success = false;
      String? error;

      try {
        final response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: body,
        );
        stopwatch.stop();

        statusCode = response.statusCode;
        success = response.statusCode == 201;

        if (success) {
          final data = jsonDecode(response.body);
          final placed = BetModel(
            betId: data['betId'],
            userId: userId,
            eventId: match.eventId,
            team: team,
            stake: amount,
            odds: odds,
            status: data['status'] ?? 'placed',
            createdAt: DateTime.parse(data['timestamp']),
            updatedAt: DateTime.parse(data['timestamp']),
            isDraft: 0,
          );
          await _repo.insertBet(placed);
          lastMessage = 'Bet placed successfully';
        } else {
          error = response.body;
          await _errorRepo.logError('/api/bets', 'BadStatus${response.statusCode}');
          lastMessage = 'Failed to place bet: ${response.statusCode}';
        }
      } catch (e) {
        stopwatch.stop();
        error = e.toString();
        await _errorRepo.logError('/api/bets', e.runtimeType.toString());
        lastMessage = 'Error placing bet: $e';
      } finally {
        await metrics_management.logApiMetric(
          endpoint: '/api/bets',
          duration: stopwatch.elapsedMilliseconds,
          statusCode: statusCode,
          success: success,
          error: error,
        );
      }
    } else {
      // ---------------- OFF‑LINE ----------------
      final draft = BetModel(
        userId: userId,
        eventId: match.acidEventId,
        team: team,
        stake: amount,
        odds: team == match.homeTeam ? oddsA : oddsB,
        matchName: match.name,
        sport: match.sport,
        status: 'placed',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isDraft: 1,
      );
      await _repo.insertBet(draft);
      _lastPlacedDraft = draft;
      lastMessage = 'Bet saved locally – will sync when back online';
    }

    notifyListeners();
  }


  /// Called by a global DraftSyncService when connectivity is restored.
  Future<void> syncDrafts() async {
    final drafts = await _repo.bulkSyncDrafts();

    for (final d in drafts) {
      //final url = Uri.parse('http://localhost:8000/api/bets');
      final url = Uri.parse('${Config.apiBaseUrl}/api/bets');
      final body = jsonEncode({
        "userId": d.userId,
        "eventId": d.eventId,
        "stake": d.stake,
        "odds": d.odds,
        "team": d.team,
      });

      final stopwatch = Stopwatch()..start();
      int? statusCode;
      bool success = false;
      String? error;

      try {
        final response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: body,
        );
        stopwatch.stop();

        statusCode = response.statusCode;
        success = response.statusCode == 201;

        if (success) {
          await _repo.markBetAsSynced(d);
        } else {
          error = response.body;
          await _errorRepo.logError(
            '/api/bets',
            'SyncBadStatus${response.statusCode}',
          );
        }
      } catch (e) {
        stopwatch.stop();
        error = e.toString();
        await _errorRepo.logError(
          '/api/bets',
          e.runtimeType.toString(),
        );
      } finally {
        await metrics_management.logApiMetric(
          endpoint: '/api/bets',
          duration: stopwatch.elapsedMilliseconds,
          statusCode: statusCode,
          success: success,
          error: error,
        );
      }
    }

    if (drafts.isNotEmpty) {
      lastMessage = 'Draft bets synced';
      notifyListeners();
    }
  }

}
