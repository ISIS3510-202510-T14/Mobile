import 'package:flutter/material.dart';
// Ajusta la ruta según tu estructura
import '../../widgets/match_card.dart';
import '../../data/models/match_model.dart';
import '../../widgets/match_card_factory.dart';

class MatchesView extends StatefulWidget {
  const MatchesView({Key? key}) : super(key: key);

  @override
  State<MatchesView> createState() => _MatchesViewState();
}

class _MatchesViewState extends State<MatchesView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Tres pestañas: Live, Upcoming, Finished
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<MatchModel> upcomingMatches = [
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
        tournament: 'ASCUN B02',
        matchId: '2',
        teamA: 'Uniandes',
        teamB: 'Javeriana',
        dateTime: DateTime(2025, 4, 4, 18, 0),
        status: 'Upcoming',
        logoTeamA: 'assets/uniandes.png',
        logoTeamB: 'assets/javeriana.png',
      ),
      // Agrega más partidos...
    ];

    final List<MatchModel> liveMatches = [
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
    minute: 53, // Current minute of the match
  ),
  MatchModel(
    tournament: 'ASCUN B05',
    matchId: '5',
    teamA: 'Team Gamma',
    teamB: 'Team Delta',
    dateTime: DateTime(2025, 4, 4, 17, 15),
    status: 'Live',
    logoTeamA: 'assets/team_gamma.png',
    logoTeamB: 'assets/team_delta.png',
    scoreTeamA: 0,
    scoreTeamB: 0,
    minute: 30,
  ),
];




    return Scaffold(
      appBar: AppBar(
        title: const Text('Matches'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Live'),
            Tab(text: 'Upcoming'),
            Tab(text: 'Finished'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          LiveMatchesTab(),
          UpcomingMatchesTab(),
          FinishedMatchesTab(),
        ],
      ),
    );
  }
}

class LiveMatchesTab extends StatelessWidget {
  const LiveMatchesTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<MatchModel> liveMatches = [
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
    minute: 53, // Current minute of the match
  ),
  MatchModel(
    tournament: 'ASCUN B05',
    matchId: '5',
    teamA: 'Team Gamma',
    teamB: 'Team Delta',
    dateTime: DateTime(2025, 4, 4, 17, 15),
    status: 'Live',
    logoTeamA: 'assets/team_gamma.png',
    logoTeamB: 'assets/team_delta.png',
    scoreTeamA: 0,
    scoreTeamB: 0,
    minute: 30,
  ),
];
    return ListView.builder(
      itemCount: liveMatches.length,
      itemBuilder: (context, index) {
        final match = liveMatches[index];
        // En vez de new MatchCard(match: match),
        // usamos la fábrica:
        return MatchCardFactory.createMatchCard(match);
      },
    );
  }
}

class UpcomingMatchesTab extends StatelessWidget {
  const UpcomingMatchesTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Ejemplo de lista local de partidos "Upcoming"
    final List<MatchModel> upcomingMatches = [
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
        tournament: 'ASCUN B02',
        matchId: '2',
        teamA: 'Uniandes',
        teamB: 'Javeriana',
        dateTime: DateTime(2025, 4, 4, 18, 0),
        status: 'Upcoming',
        logoTeamA: 'assets/uniandes.png',
        logoTeamB: 'assets/javeriana.png',
      ),
      // Agrega más partidos de ejemplo...
    ];

    return ListView.builder(
      itemCount: upcomingMatches.length,
      itemBuilder: (context, index) {
        final match = upcomingMatches[index];
        // En vez de new MatchCard(match: match),
        // usamos la fábrica:
        return MatchCardFactory.createMatchCard(match);
      },
    );
  }
}

class FinishedMatchesTab extends StatelessWidget {
  const FinishedMatchesTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sample list for finished matches
final List<MatchModel> finishedMatches = [
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
  MatchModel(
    tournament: 'ASCUN B03',
    matchId: '3',
    teamA: 'Team X',
    teamB: 'Team Y',
    dateTime: DateTime(2025, 4, 4, 17, 0),
    status: 'Finished',
    logoTeamA: 'assets/team_x.png',
    logoTeamB: 'assets/team_y.png',
    scoreTeamA: 0,
    scoreTeamB: 0,
  ),
];
    return ListView.builder(
      itemCount: finishedMatches.length,
      itemBuilder: (context, index) {
        final match = finishedMatches[index];
        // En vez de new MatchCard(match: match),
        // usamos la fábrica:
        return MatchCardFactory.createMatchCard(match);
      },
    );
  }
}
