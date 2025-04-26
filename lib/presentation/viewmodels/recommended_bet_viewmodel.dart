// lib/presentation/viewmodels/recommended_bet_viewmodel.dart

import 'dart:convert';
import 'package:campus_picks/data/services/metrics_management.dart' as metrics_management;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../data/models/recommended_bet_model.dart';
import '../../data/repositories/error_log_repository.dart';

class RecommendedBetsViewModel extends ChangeNotifier {
  final ErrorLogRepository _errorRepo = ErrorLogRepository();

  List<RecommendedBet> _recommendedBets = [];
  bool _loading = false;
  String? _error;

  List<RecommendedBet> get recommendedBets => _recommendedBets;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> fetchRecommendedBets() async {
    _loading = true;
    notifyListeners();

    final userId = FirebaseAuth.instance.currentUser?.uid;
    final endpoint = '/api/events/recommended';
    final url = Uri.parse('http://localhost:8000$endpoint?userId=$userId');

    final startTime = DateTime.now();
    int duration;
    bool success = false;
    int? statusCode;
    String? error;

    try {
      final response = await http.get(url);

      duration = DateTime.now().difference(startTime).inMilliseconds;
      statusCode = response.statusCode;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> betsJson = data['recommendedBets'] as List<dynamic>;
        _recommendedBets = betsJson
            .map((j) => RecommendedBet.fromJson(j as Map<String, dynamic>))
            .toList();
        _error = null;
        success = true;
      } else {
        error = 'BadStatus${response.statusCode}';
        await _errorRepo.logError(endpoint, error);
        _error = 'Error: ${response.statusCode}';
      }
    } catch (e) {
      duration = DateTime.now().difference(startTime).inMilliseconds;
      error = e.runtimeType.toString();
      await _errorRepo.logError(endpoint, error);
      _error = e.toString();
    }

    // Log the API metric
    await metrics_management.logApiMetric(
      endpoint: endpoint,
      duration: duration,
      statusCode: statusCode,
      success: success,
      error: error,
    );

    _loading = false;
    print('Recommended bets fetched: $_recommendedBets');
    await metrics_management.sendPendingMetrics();
    notifyListeners();
  }
}
