// lib/presentation/viewmodels/user_bets_view_model.dart

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

class UserBetsViewModel extends ChangeNotifier {
  final BetRepository      _betRepo     = BetRepository();
  final MatchRepository    _matchRepo   = MatchRepository();
  final ErrorLogRepository _errorRepo   = ErrorLogRepository();
  final ConnectivityNotifier connectivityNotifier;

  UserBetsViewModel({required this.connectivityNotifier});

  List<BetWithMatch> _bets = [];
  bool               _loading = false;
  String?            _error;

  /// Tracks if remote fetch has run in the current app session (shared across instances)
  static bool        _hasLoadedOnce = false;

  List<BetWithMatch> get bets    => _bets;
  bool               get loading => _loading;
  String?            get error   => _error;

  /// Injects a just-saved offline draft into the list without hitting SQLite again.
  void addLocalBet(BetModel b) {
    _bets.insert(0, BetWithMatch(bet: b, match: null));
    notifyListeners();
  }

  /// Loads the betting history: always reads from local first,
  /// then calls remote only once per session or when forced.
    /// Loads the betting history: always reads from local first,
  /// then calls remote only once per session or when forced.
  Future<void> loadBets(String userId, {bool forceRemote = false}) async {
    _loading = true;
    notifyListeners();

    final bool online = connectivityNotifier.isOnline;
    List<BetModel> raw = [];

    // 1) Always load from local SQLite
    try {
      raw = await _betRepo.getBetsForUser(userId);
    } catch (e) {
      await _errorRepo.logError('local_db_bets', e.runtimeType.toString());
    }

    // 2) Only fetch remote once per session or if explicitly forced
    if (online && (forceRemote || !_hasLoadedOnce)) {
      final uri = Uri.http('localhost:8000', '/api/bets/history', {'userId': userId});
      try {
        final res = await http.get(uri).timeout(const Duration(seconds: 6));
        if (res.statusCode == 200) {
          final fresh = (jsonDecode(res.body)['bets'] as List)
              .map((j) => BetModel.fromJson(j as Map<String, dynamic>))
              .toList();
          raw = fresh;
          await _betRepo.replaceAllForUser(userId, raw);
          // Mark as loaded only on successful 200 response
          _hasLoadedOnce = true;
        } else {
          await _errorRepo.logError(
            '/api/bets/history',
            'BadStatus${res.statusCode}',
          );
          throw HttpException('Backend returned ${res.statusCode}');
        }
      } catch (e) {
        await _errorRepo.logError(
          '/api/bets/history',
          e.runtimeType.toString(),
        );
        debugPrint('UserBetsViewModel: remote fetch failed → $e');
        // don't set _hasLoadedOnce here so we retry on next call
      }
    }

    // 3) Enrich with match data and update UI
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
