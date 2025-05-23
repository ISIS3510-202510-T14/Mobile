import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/match_model.dart';
import '../viewmodels/matches_view_model.dart';
import '../widgets/match_card_factory.dart';
import '../../data/services/connectivity_service.dart';
import 'package:campus_picks/data/services/auth.dart';
import 'package:campus_picks/presentation/screens/login_screen.dart';

class MatchesView extends StatefulWidget {
  const MatchesView({Key? key}) : super(key: key);

  @override
  State<MatchesView> createState() => _MatchesViewState();
}

class _MatchesViewState extends State<MatchesView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late MatchesViewModel _matchesViewModel;
  late ConnectivityNotifier _conn;
  bool _wasOffline = false;
  String? selectedSport;
  bool _showOnlyFavorites = false; // Nuevo flag para filtro

  @override
  void initState() {
    super.initState();
    
    _tabController = TabController(length: 3, vsync: this);

    _conn = context.read<ConnectivityNotifier>();
    _matchesViewModel = MatchesViewModel(connectivityNotifier: _conn);
    _conn.addListener(_onConnectivityChanged);

    _matchesViewModel.fetchMatchesWithFavorites().then((_) {
      _matchesViewModel.checkProximityAndNotify();
    }).catchError((error) {
      _matchesViewModel.checkProximityAndNotify();
      print('Error al obtener los partidos: $error');
    });
    _matchesViewModel.sendUserLocation().then((_) {}).catchError((error) {
      print('Error al enviar la ubicación del usuario: $error');
    });

    
  }
 void _onConnectivityChanged() {
    final offline = _conn.isOnline == false;

    // mostrar snackbar SOLO al pasar de online → offline
    if (offline && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Offline mode – showing cached data'),
          duration: Duration(seconds: 3),
        ),
      );
    }

    // si vuelve la conexión refrescamos partidos
    if (!offline) {
      _matchesViewModel.fetchMatchesWithFavorites();
    }
    // rebuild para pintar/ocultar la franja amarilla
    if (mounted) setState(() {});
    print("CallBack de matches view para cambios de conectividad");
  }


  @override
  void dispose() {
    _conn.removeListener(_onConnectivityChanged);
    _tabController.dispose();
    _matchesViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
  final primaryColor = Theme.of(context).colorScheme.primary;

  // ← status de red (viene del ConnectivityNotifier inyectado en main)
  final bool offline = _conn.isOnline == false;

  return ChangeNotifierProvider<MatchesViewModel>.value(
    value: _matchesViewModel,
    child: Consumer<MatchesViewModel>(
      builder: (context, viewModel, child) {
        // ---------------- filtros ----------------
        final filteredLiveMatches = viewModel.liveMatches.where((m) {
          final sportOk = selectedSport == null ||
              m.sport.toLowerCase() == selectedSport;
          final favOk = !_showOnlyFavorites || m.isFavorite;
          return sportOk && favOk;
        }).toList();

        final filteredUpcomingMatches = viewModel.upcomingMatches.where((m) {
          final sportOk = selectedSport == null ||
              m.sport.toLowerCase() == selectedSport;
          final favOk = !_showOnlyFavorites || m.isFavorite;
          return sportOk && favOk;
        }).toList();

        final filteredFinishedMatches = viewModel.finishedMatches.where((m) {
          final sportOk = selectedSport == null ||
              m.sport.toLowerCase() == selectedSport;
          final favOk = !_showOnlyFavorites || m.isFavorite;
          return sportOk && favOk;
        }).toList();

        // ---------------- UI ----------------
        return Scaffold(
          appBar: AppBar(
            title: const Text('Matches'),
            actions: [
              IconButton(
                icon: const Icon(Icons.exit_to_app),
                tooltip: 'Logout',
                onPressed: () async {
                  await authService.value.signOut();
                  if (mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  }
                },
              ),
              IconButton(
                icon: Icon(
                  _showOnlyFavorites ? Icons.star : Icons.star_border,
                ),
                tooltip: 'Show Favorites Only',
                onPressed: () {
                  setState(() => _showOnlyFavorites = !_showOnlyFavorites);
                },
              ),
            ],
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(offline ? 100 : 80),
              child: Column(
                children: [
                  // ---------- banner OFF‑LINE ----------
                  if (offline)
                    Container(
                      height: 20,
                      width: double.infinity,
                      color: primaryColor,
                      alignment: Alignment.center,
                      child: const Text(
                        'OFF‑LINE  •  using cached data',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),

                  // ---------- filtro de deporte ----------
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
                          onSelected: (sel) {
                            setState(() =>
                                selectedSport = sel ? 'football' : null);
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
                          onSelected: (sel) {
                            setState(() =>
                                selectedSport = sel ? 'basketball' : null);
                          },
                          selectedColor: primaryColor,
                        ),
                      ],
                    ),
                  ),

                  // // ---------- tabs ----------
                  // TabBar(
                  //   controller: _tabController,
                  //   tabs: const [
                  //     Tab(text: 'Live'),
                  //     Tab(text: 'Upcoming'),
                  //     Tab(text: 'Finished'),
                  //   ],
                  // ),
                   TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: 'Live'),
                      Tab(text: 'Upcoming'),
                      Tab(text: 'Finished'),
                    ],
                  )
                ],
              ),
            ),
          ),

          // ---------- contenido por pestañas ----------
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
    //-- Before micro-optimizations-- 
    // return ListView.builder(
    //   itemCount: liveMatches.length,
    //   itemBuilder: (context, index) {
    //     final match = liveMatches[index];
    //     return MatchCardFactory.createMatchCard(match);
    //   },
    // );


  return ListView.builder(
      itemCount: liveMatches.length,
      itemExtent: 250,   // altura fija aproximada de la tarjeta
      cacheExtent: 600,  // precarga 5 ítems fuera de pantalla
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
    //-- Before micro-optimizations--
    // return ListView.builder(
    //   itemCount: upcomingMatches.length,
    //   itemBuilder: (context, index) {
    //     final match = upcomingMatches[index];
    //     return MatchCardFactory.createMatchCard(match);
    //   },
    // );


    // Before micro-optimizations
    return ListView.builder(
      itemCount: upcomingMatches.length,
      itemExtent: 250,   // altura fija aproximada de la tarjeta
      cacheExtent: 600,  // precarga 5 ítems fuera de pantalla
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
    // return ListView.builder(
    //   itemCount: finishedMatches.length,
    //   itemBuilder: (context, index) {
    //     final match = finishedMatches[index];
    //     return MatchCardFactory.createMatchCard(match);
    //   },
    // );

      return ListView.builder(
          itemCount: finishedMatches.length,
        itemExtent: 200,   // altura fija aproximada de la tarjeta
        cacheExtent: 600,  // precarga 5 ítems fuera de pantalla
          itemBuilder: (ctx, i) =>
              MatchCardFactory.createMatchCard(finishedMatches[i]),
      );

  

  }
}
