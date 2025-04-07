// ViewModel para las apuestas recomendadas

import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../data/models/recommended_bet_model.dart';
class RecommendedBetsViewModel extends ChangeNotifier {
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
    try {
      // Se utiliza el endpoint que espera userId en la query string
      final url = Uri.parse("http://localhost:8000/api/events/recommended/?userId=$userId");
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> betsJson = data['recommendedBets'];
        print ("Bets JSON: $betsJson");
        _recommendedBets = betsJson.map((json) => RecommendedBet.fromJson(json)).toList();
        _error = null;
      } else {
        _error = "Error: ${response.statusCode}";
      }
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }
}