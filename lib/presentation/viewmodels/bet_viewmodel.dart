// lib/presentation/viewmodels/bet_viewmodel.dart
// UPDATED – supports offline flag, writes isDraft, fixes syncDrafts, removes connectivity listener

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../data/models/bet_model.dart';
import '../../data/models/match_model.dart';
import '../../data/services/connectivity_service.dart';
import '../../data/repositories/bet_repository.dart';

class BetViewModel extends ChangeNotifier {
  final MatchModel match;
  final String userId;
  final ConnectivityNotifier connectivity;
  final BetRepository _repo = BetRepository();
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
      final url = Uri.parse('http://localhost:8000/api/bets');
      final odds = team == match.homeTeam ? oddsA : oddsB;
      final body = jsonEncode({
        "userId": userId,
        "eventId": match.acidEventId, // backend expects acidEventId
        "stake": amount,
        "odds": odds,
        "team": team,
      });

      try {
        final response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: body,
        );

        if (response.statusCode == 201) {
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
          lastMessage = 'Failed to place bet: ${response.statusCode}';
        }
      } catch (e) {
        lastMessage = 'Error placing bet: $e';
      }
    } else {
      // ---------------- OFF‑LINE ----------------
      final draft = BetModel(
        userId: userId,
        eventId: match.acidEventId,
        team: team,
        stake: amount,
        odds: team == match.homeTeam ? oddsA : oddsB,
        matchName : match.name,
        sport     : match.sport, 
        status: 'placed',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isDraft: 1,
      );
      await _repo.insertBet(draft);
      _lastPlacedDraft = draft;            // make it available to PlaceBetView
      lastMessage = 'Bet saved locally – will sync when back online';
    }

    notifyListeners();
  }

  /// Called by a global DraftSyncService when connectivity is restored.
  Future<void> syncDrafts() async {
    final drafts = await _repo.bulkSyncDrafts();

    for (final d in drafts) {
      final url = Uri.parse('http://localhost:8000/api/bets');
      final body = jsonEncode({
        "userId": d.userId,
        "eventId": d.eventId, // send the draft's own eventId
        "stake": d.stake,
        "odds": d.odds,
        "team": d.team,
      });

      try {
        final response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: body,
        );
        if (response.statusCode == 201) {
          await _repo.markBetAsSynced(d);
        }
      } catch (_) {
        // leave it for next retry
      }
    }

    if (drafts.isNotEmpty) {
      lastMessage = 'Draft bets synced';
      notifyListeners();
    }
  }
}
