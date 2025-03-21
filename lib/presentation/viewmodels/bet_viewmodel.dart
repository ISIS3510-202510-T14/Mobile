import '../../data/models/match_model.dart';
import 'dart:math';

class BetViewModel {
  final MatchModel match;
  final String userId;
  late double oddsA;
  late double oddsB;
  
  BetViewModel({required this.match, required this.userId}) {
    _generateRandomOdds();
  }
  
  void _generateRandomOdds() {
    final rand = Random();
    oddsA = (rand.nextDouble() * 1.5) + 1.0;
    oddsB = (rand.nextDouble() * 1.5) + 1.0;
  }
}