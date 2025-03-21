import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/match_model.dart';
import '../viewmodels/matches_view_model.dart';
import '../widgets/match_card_factory.dart';

class MatchesView extends StatefulWidget {
  const MatchesView({Key? key}) : super(key: key);

  @override
  State<MatchesView> createState() => _MatchesViewState();
}

class _MatchesViewState extends State<MatchesView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late MatchesViewModel _matchesViewModel;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _matchesViewModel = MatchesViewModel();

    // Llamamos al método para obtener los datos del API.
    // Es buena idea manejar errores en producción.
    _matchesViewModel.fetchMatches().catchError((error) {
      // Aquí podrías mostrar un mensaje de error, por ejemplo.
      print('Error al obtener los partidos: $error');
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _matchesViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MatchesViewModel>.value(
      value: _matchesViewModel,
      child: Consumer<MatchesViewModel>(
        builder: (context, viewModel, child) {
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
                LiveMatchesTab(liveMatches: viewModel.liveMatches),
                UpcomingMatchesTab(upcomingMatches: viewModel.upcomingMatches),
                FinishedMatchesTab(finishedMatches: viewModel.finishedMatches),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Pestaña de partidos en vivo
class LiveMatchesTab extends StatelessWidget {
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

// Pestaña de partidos próximos
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

// Pestaña de partidos finalizados
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
