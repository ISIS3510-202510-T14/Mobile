// lib/viewmodels/matches_view_model.dart
import 'package:flutter/material.dart';
import '../../data/models/match_model.dart';

class MatchesViewModel extends ChangeNotifier {
  // Hardcoded list of matches (for now)
  final List<MatchModel> _matches = [
    MatchModel(
      tournament: 'ASCUN B01',
      matchId: '1',
      teamA: 'U. Rosario',
      teamB: 'U. Sabana',
      dateTime: DateTime(2025, 4, 4, 15, 0),
      status: 'Upcoming',
      logoTeamA: 'assets/rosario.png',
      logoTeamB: 'assets/sabana.png',
    ),
    MatchModel(
      tournament: 'ASCUN B04',
      matchId: '4',
      teamA: 'Team Alpha',
      teamB: 'Team Beta',
      dateTime: DateTime(2025, 4, 4, 16, 30),
      status: 'Live',
      logoTeamA: 'assets/team_alpha.png',
      logoTeamB: 'assets/team_beta.png',
      scoreTeamA: 1,
      scoreTeamB: 2,
      minute: 53,
    ),
    MatchModel(
      tournament: 'ASCUN B02',
      matchId: '2',
      teamA: 'Uniandes',
      teamB: 'Javeriana',
      dateTime: DateTime(2025, 4, 4, 18, 0),
      status: 'Finished',
      logoTeamA: 'assets/uniandes.png',
      logoTeamB: 'assets/javeriana.png',
      scoreTeamA: 2,
      scoreTeamB: 1,
    ),
   
  ];

  // Expose filtered lists
  List<MatchModel> get liveMatches =>
      _matches.where((match) => match.status == 'Live').toList();

  List<MatchModel> get upcomingMatches =>
      _matches.where((match) => match.status == 'Upcoming').toList();

  List<MatchModel> get finishedMatches =>
      _matches.where((match) => match.status == 'Finished').toList();


  Future<void> loadMatches() async {

  }
}
