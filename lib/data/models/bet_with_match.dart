// lib/data/models/bet_with_match.dart
import 'bet_model.dart';
import 'match_model.dart';

class BetWithMatch {
  final BetModel bet;
  final MatchModel? match;

  BetWithMatch({required this.bet, this.match});
}
