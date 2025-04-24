// lib/presentation/viewmodels/recommended_bet_viewmodel.dart

import 'dart:convert';
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
    final url = Uri.parse(
      'http://10.0.2.2:8000/api/events/recommended?userId=$userId',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> betsJson = data['recommendedBets'] as List<dynamic>;
        _recommendedBets = betsJson
            .map((j) => RecommendedBet.fromJson(j as Map<String, dynamic>))
            .toList();
        _error = null;
      } else {
        // Log unexpected status codes
        await _errorRepo.logError(
          '/api/events/recommended',
          'BadStatus${response.statusCode}',
        );
        _error = 'Error: ${response.statusCode}';
      }
    } catch (e) {
      // Log exceptions (connectivity, parsing, etc.)
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
