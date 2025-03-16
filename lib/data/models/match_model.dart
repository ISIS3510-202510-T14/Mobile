// lib/data/models/match_model.dart
class MatchModel {
  final String tournament;
  final String matchId;
  final String teamA;
  final String teamB;
  final DateTime dateTime;
  final String status; // "Live", "Upcoming", "Finished", etc.
  final String logoTeamA; 
  final String logoTeamB;


// Fields for a finished match
  final int? scoreTeamA;
  final int? scoreTeamB;

  // For live matches, we can store the minute or time elapsed
  final int? minute;

  MatchModel({
    required this.tournament,
    required this.matchId,
    required this.teamA,
    required this.teamB,
    required this.dateTime,
    required this.status,
    required this.logoTeamA,
    required this.logoTeamB,
    this.scoreTeamA,
    this.scoreTeamB,
    this.minute,
  });
}
