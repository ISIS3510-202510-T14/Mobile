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

class _MatchesViewState extends State<MatchesView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late MatchesViewModel _matchesViewModel;

  // Variable para el filtro de deporte; null significa que no hay filtro seleccionado.
  String? selectedSport;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _matchesViewModel = MatchesViewModel();

    _matchesViewModel.fetchMatches().then((_) {
      // Una vez obtenidos, verificamos la proximidad y notificamos si corresponde
      _matchesViewModel.checkProximityAndNotify();
    }).catchError((error) {
      _matchesViewModel.checkProximityAndNotify();
      
      
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
    final primaryColor = Theme.of(context).colorScheme.primary;
    return ChangeNotifierProvider<MatchesViewModel>.value(
      value: _matchesViewModel,
      child: Consumer<MatchesViewModel>(
        builder: (context, viewModel, child) {
          // Si no hay filtro seleccionado, usamos todas las listas; de lo contrario filtramos.
          final filteredLiveMatches = selectedSport == null
              ? viewModel.liveMatches
              : viewModel.liveMatches
                  .where((m) => m.sport.toLowerCase() == selectedSport)
                  .toList();
          final filteredUpcomingMatches = selectedSport == null
              ? viewModel.upcomingMatches
              : viewModel.upcomingMatches
                  .where((m) => m.sport.toLowerCase() == selectedSport)
                  .toList();
          final filteredFinishedMatches = selectedSport == null
              ? viewModel.finishedMatches
              : viewModel.finishedMatches
                  .where((m) => m.sport.toLowerCase() == selectedSport)
                  .toList();

          return Scaffold(
            appBar: AppBar(
              title: const Text('Matches'),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(80),
                child: Column(
                  children: [
                    // Filtro de deporte usando ChoiceChips con iconos
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ChoiceChip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.sports_soccer, size: 20),
                                SizedBox(width: 4),
                                Text("Football"),
                              ],
                            ),
                            selected: selectedSport == 'football',
                            onSelected: (selected) {
                              setState(() {
                                selectedSport = selected ? 'football' : null;
                              });
                            },
                            selectedColor: primaryColor,
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.sports_basketball, size: 20),
                                SizedBox(width: 4),
                                Text("Basketball"),
                              ],
                            ),
                            selected: selectedSport == 'basketball',
                            onSelected: (selected) {
                              setState(() {
                                selectedSport = selected ? 'basketball' : null;
                              });
                            },
                            selectedColor: primaryColor,
                          ),
                        ],
                      ),
                    ),
                    // Pestañas
                    TabBar(
                      controller: _tabController,
                      tabs: const [
                        Tab(text: 'Live'),
                        Tab(text: 'Upcoming'),
                        Tab(text: 'Finished'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: [
                LiveMatchesTab(liveMatches: filteredLiveMatches),
                UpcomingMatchesTab(upcomingMatches: filteredUpcomingMatches),
                FinishedMatchesTab(finishedMatches: filteredFinishedMatches),
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
  const UpcomingMatchesTab({Key? key, required this.upcomingMatches})
      : super(key: key);

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
  const FinishedMatchesTab({Key? key, required this.finishedMatches})
      : super(key: key);

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
