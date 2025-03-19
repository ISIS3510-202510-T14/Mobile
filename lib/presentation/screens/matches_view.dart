import 'package:flutter/material.dart';
import '../widgets/match_card.dart';
import '../../data/models/match_model.dart';
import '../widgets/match_card_factory.dart';

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
    // Three tabs: Live, Upcoming, Finished
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // These lists are just examples for demonstration
    final List<MatchModel> upcomingMatches = [
      MatchModel(
        tournament: 'ASCUN B01',
        matchId: '1',
        teamA: 'U. Rosario',
        teamB: 'U. Sabana',
        dateTime: DateTime(2025, 4, 4, 15, 0),
        status: 'Upcoming',
        // Corrected image paths
        logoTeamA: 'assets/images/rosario.png',
        logoTeamB: 'assets/images/sabana.png',
      ),
      MatchModel(
        tournament: 'ASCUN B02',
        matchId: '2',
        teamA: 'Uniandes',
        teamB: 'Javeriana',
        dateTime: DateTime(2025, 4, 4, 18, 0),
        status: 'Upcoming',
        logoTeamA: 'assets/images/uniandes.png',
        logoTeamB: 'assets/images/javeriana.png',
      ),
    ];

    final List<MatchModel> liveMatches = [
      MatchModel(
        tournament: 'ASCUN B04',
        matchId: '4',
        teamA: 'Team Alpha',
        teamB: 'Team Beta',
        dateTime: DateTime(2025, 4, 4, 16, 30),
        status: 'Live',
        logoTeamA: 'assets/images/team_alpha.png',
        logoTeamB: 'assets/images/team_beta.png',
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
        logoTeamA: 'assets/images/team_gamma.png',
        logoTeamB: 'assets/images/team_delta.png',
        scoreTeamA: 0,
        scoreTeamB: 0,
        minute: 30,
      ),
    ];

    final List<MatchModel> finishedMatches = [
      MatchModel(
        tournament: 'ASCUN B02',
        matchId: '2',
        teamA: 'Uniandes',
        teamB: 'Javeriana',
        dateTime: DateTime(2025, 4, 4, 18, 0),
        status: 'Finished',
        logoTeamA: 'assets/images/uniandes.png',
        logoTeamB: 'assets/images/javeriana.png',
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
        logoTeamA: 'assets/images/team_gamma.png', // Example image
        logoTeamB: 'assets/images/team_beta.png',  // Corrected from "team_betta"
        scoreTeamA: 0,
        scoreTeamB: 0,
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
        children: [
          // Live tab: show liveMatches in a ListView
          LiveMatchesTab(liveMatches: liveMatches),
          // Upcoming tab: show upcomingMatches in a ListView
          UpcomingMatchesTab(upcomingMatches: upcomingMatches),
          // Finished tab: show finishedMatches in a ListView
          FinishedMatchesTab(finishedMatches: finishedMatches),
        ],
      ),
    );
  }
}

// Live tab
class LiveMatchesTab extends StatelessWidget {
  // We pass the list via constructor
  final List<MatchModel> liveMatches;
  const LiveMatchesTab({Key? key, required this.liveMatches}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: liveMatches.length,
      itemBuilder: (context, index) {
        final match = liveMatches[index];
        return MatchCardFactory.createMatchCard(match);
      },
    );
  }
}

// Upcoming tab
class UpcomingMatchesTab extends StatelessWidget {
  final List<MatchModel> upcomingMatches;
  const UpcomingMatchesTab({Key? key, required this.upcomingMatches}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: upcomingMatches.length,
      itemBuilder: (context, index) {
        final match = upcomingMatches[index];
        return MatchCardFactory.createMatchCard(match);
      },
    );
  }
}

// Finished tab
class FinishedMatchesTab extends StatelessWidget {
  final List<MatchModel> finishedMatches;
  const FinishedMatchesTab({Key? key, required this.finishedMatches}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: finishedMatches.length,
      itemBuilder: (context, index) {
        final match = finishedMatches[index];
        return MatchCardFactory.createMatchCard(match);
      },
    );
  }
}
