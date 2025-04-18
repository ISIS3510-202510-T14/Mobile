import '../../data/models/match_model.dart';

class BetViewModel {
  final MatchModel match;
  final String userId;
  late final double oddsA;
  late final double oddsB;

  BetViewModel({
    required this.match,
    required this.userId,
  }) {
    oddsA = match.oddsA;
    oddsB = match.oddsB;
  }
}