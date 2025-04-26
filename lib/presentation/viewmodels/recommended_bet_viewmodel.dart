import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../data/models/recommended_bet_model.dart';
import '../../data/repositories/error_log_repository.dart';
import '../../data/repositories/recommended_bet_repository.dart';
import 'package:campus_picks/src/config.dart';

class RecommendedBetsViewModel extends ChangeNotifier {
  final ErrorLogRepository _errorRepo = ErrorLogRepository();
  final RecommendedBetRepository _recommendedBetRepository = RecommendedBetRepository();

  List<RecommendedBet> recommendedBets = [];
  bool _loading = false;
  String? _error;

  bool get loading => _loading;
  String? get error => _error;

  RecommendedBetsViewModel();

  Future<void> fetchRecommendedBets() async {
    _loading = true;
    notifyListeners();

    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      final bool isOffline = connectivityResult == ConnectivityResult.none;
      final userId = FirebaseAuth.instance.currentUser?.uid;

      print('Connectivity status: $connectivityResult');
      print('Is offline: $isOffline');

      if (isOffline) {
        recommendedBets = await _recommendedBetRepository.getAllRecommendedBets();
      } else {
        final url = Uri.parse(
          '${Config.apiBaseUrl}/api/events/recommended?userId=$userId',
        );
        final response = await http.get(url);

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final List<dynamic> betsJson = data['recommendedBets'] as List<dynamic>;
          recommendedBets = betsJson
              .map((j) => RecommendedBet.fromJson(j as Map<String, dynamic>))
              .toList();
          _error = null;

          if (recommendedBets.isNotEmpty) {
            for (var bet in recommendedBets) {
              await _recommendedBetRepository.insertRecommendedBet(bet);
            }
          }
        } else {
          await _errorRepo.logError(
            '/api/events/recommended',
            'BadStatus${response.statusCode}',
          );
          _error = 'Error: ${response.statusCode}';
        }
      }
    } catch (e) {
      await _errorRepo.logError(
        '/api/events/recommended',
        e.runtimeType.toString(),
      );
      _error = e.toString();
    }

    _loading = false;
    notifyListeners();
  }
}
