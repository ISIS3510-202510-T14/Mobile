// lib/presentation/viewmodels/user_bets_view_model.dart
//
// v2 – 2025‑04‑18
// • loadBets(): always falls back to SQLite on *any* remote error.
// • clearer variable names + extra logging.

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:campus_picks/data/models/bet_model.dart';
import 'package:campus_picks/data/models/match_model.dart';
import 'package:campus_picks/data/models/bet_with_match.dart';

import 'package:campus_picks/data/repositories/bet_repository.dart';
import 'package:campus_picks/data/repositories/match_repository.dart';
import 'package:campus_picks/data/repositories/error_log_repository.dart';

import 'package:campus_picks/data/services/connectivity_service.dart';
import 'package:campus_picks/data/services/metrics_management.dart' as metrics_management;


class UserBetsViewModel extends ChangeNotifier {
  final BetRepository     _betRepo     = BetRepository();
  final MatchRepository   _matchRepo   = MatchRepository();
  final ErrorLogRepository _errorRepo  = ErrorLogRepository();
  final ConnectivityNotifier connectivityNotifier;

  UserBetsViewModel({required this.connectivityNotifier});

  List<BetWithMatch> _bets = [];
  bool    _loading = false;
  String? _error;

  List<BetWithMatch> get bets    => _bets;
  bool               get loading => _loading;
  String?            get error   => _error;

  //──────────────────────────────────────────────────────────────────────
  //  Inject a just‑saved *offline draft* into the list without touching
  //  SQLite – the screen refreshes instantly and we avoid extra I/O.
  //──────────────────────────────────────────────────────────────────────
  void addLocalBet(BetModel b) {
    _bets.insert(0, BetWithMatch(bet: b, match: null));
    notifyListeners();
  }

  /// Loads the betting history – resilient to:
  /// • no connectivity  • backend down  • timeouts.
  Future<void> loadBets(String userId, {bool forceRemote = false}) async {
    _loading = true;
    notifyListeners();

    final bool online = connectivityNotifier.isOnline;
    List<BetModel> raw = [];

    final stopwatch = Stopwatch();
    int? statusCode;
    bool success = false;
    String? error;

    // ------------------------------------------------------------
    // ① TRY REMOTE (only if online & asked to)
    // ------------------------------------------------------------
    if (online && (forceRemote || _bets.isEmpty)) {
      final host = 'localhost:8000';
      final uri  = Uri.http(host, '/api/bets/history', {'userId': userId});
      stopwatch.start();

      try {
        final res = await http.get(uri).timeout(const Duration(seconds: 6));

        stopwatch.stop();
        statusCode = res.statusCode;
        success = res.statusCode == 200;

        if (res.statusCode == 200) {
          final fresh = (jsonDecode(res.body)['bets'] as List)
              .map((j) => BetModel.fromJson(j as Map<String, dynamic>))
              .toList();

          if (fresh.isNotEmpty) {
            raw = fresh;
            await _betRepo.replaceAllForUser(userId, raw);
          }
        } else {
          error = res.body;
          await _errorRepo.logError(
            '/api/bets/history',
            'BadStatus${res.statusCode}',
          );
          throw HttpException('Backend returned ${res.statusCode}');
        }
      } catch (e, s) {
        stopwatch.stop();
        error = e.toString();
        await _errorRepo.logError(
          '/api/bets/history',
          e.runtimeType.toString(),
        );
        debugPrint('UserBetsViewModel: remote fetch failed → $e\n$s');
      } finally {
        await metrics_management.logApiMetric(
          endpoint: '/api/bets/history',
          duration: stopwatch.elapsedMilliseconds,
          statusCode: statusCode,
          success: success,
          error: error,
        );
      }
    }

    // ------------------------------------------------------------
    // ② LOCAL FALLBACK  (covers: offline **or** remote‑fetch error)
    // ------------------------------------------------------------
    if (raw.isEmpty) {
      try {
        raw = await _betRepo.getBetsForUser(userId);
      } catch (e, s) {
        await _errorRepo.logError(
          'local_db_bets',
          e.runtimeType.toString(),
        );
        _error = e.toString();
        debugPrint('UserBetsViewModel: local fetch failed → $e\n$s');
      }
    }

    // ------------------------------------------------------------
    // ③ ENRICH  + expose to UI
    // ------------------------------------------------------------
    if (raw.isNotEmpty) {
      _bets = await Future.wait(raw.map((b) async {
        final MatchModel? m = await _matchRepo.getMatch(b.eventId);
        return BetWithMatch(bet: b, match: m);
      }));
      _error = null;
    } else if (_error == null) {
      _bets = [];
    }

    _loading = false;
    notifyListeners();
  }
  
}
