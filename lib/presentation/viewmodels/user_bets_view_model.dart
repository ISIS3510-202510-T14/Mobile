import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:campus_picks/data/models/bet_model.dart';
import 'package:campus_picks/data/models/match_model.dart';
import 'package:campus_picks/data/models/bet_with_match.dart';

import 'package:campus_picks/data/repositories/bet_repository.dart';
import 'package:campus_picks/data/repositories/match_repository.dart';

import 'package:campus_picks/data/services/connectivity_service.dart';

class UserBetsViewModel extends ChangeNotifier {
  final BetRepository   _betRepository   = BetRepository();
  final MatchRepository _matchRepository = MatchRepository();
  final ConnectivityNotifier connectivityNotifier;

  UserBetsViewModel({required this.connectivityNotifier});

  List<BetWithMatch> _bets = [];
  bool   _loading = false;
  String? _error;

  List<BetWithMatch> get bets   => _bets;
  bool get loading              => _loading;
  String? get error             => _error;

  Future<void> loadBets(String userId) async {
    _loading = true;
    notifyListeners();

    final bool offline = !connectivityNotifier.isOnline;
    List<BetModel> rawBets = [];

    try {
      // ------------------------ fetch bets ------------------------
      if (offline) {
        // local cache only
        rawBets = await _betRepository.getBetsForUser(userId);
      } else {
        final uri = Uri.http(
          'localhost:8000',
          '/api/bets/history',
          {'userId': userId},
        );

        final res = await http.get(uri).timeout(const Duration(seconds: 6));

        if (res.statusCode == 200) {
          final List<dynamic> jsonList = jsonDecode(res.body)['bets'];
          rawBets = jsonList.map((e) => BetModel.fromJson(e)).toList();

          // persist in SQLite for off‑line use
          for (final b in rawBets) {
            await _betRepository.insertBet(b);
          }
        } else {
          // fall back to local cache if the server responded with an error
          rawBets = await _betRepository.getBetsForUser(userId);
        }
      }
      _error = null;
    } catch (e) {
      // network failure → use whatever we have locally
      _error = e.toString();
      rawBets = await _betRepository.getBetsForUser(userId);
    }

    // ------------------------ enrich with Match data ------------------------
    _bets = [];
    for (final b in rawBets) {
      final MatchModel? match = await _matchRepository.getMatch(b.eventId);
      _bets.add(BetWithMatch(bet: b, match: match));
    }

    _loading = false;
    notifyListeners();
  }
}
