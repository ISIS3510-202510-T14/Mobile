import 'package:campus_picks/presentation/screens/user_bets_screen.dart';
import 'package:flutter/material.dart';
import 'matches_view.dart';
import "recommended_bet_screen.dart"; // Asegúrate de importar tu pantalla de RecommendedBets
import 'marketplace_screen.dart';

class HomeNav extends StatefulWidget {
  const HomeNav({Key? key}) : super(key: key);

  @override
  State<HomeNav> createState() => _HomeNavState();
}

class _HomeNavState extends State<HomeNav> {
  int _currentIndex = 0;

  // Definimos las pantallas: MatchesView y RecommendedBetsScreen son navegables,
  // mientras que las demás son placeholders.
  final List<Widget> _screens = [
    const MatchesView(), // Índice 0: Matches
    const RecommendedBetsScreen(), // Índice 1: Recommended Bets
    const UserBetsScreen(),
    const MarketplaceScreen(), // Índice 3: Marketplace
    const Placeholder(), // Índice 4: Profile (Coming soon)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        onTap: (int index) {
          // We can nagivate to the first four screens, but the last is placeholder.
          if (index <= 3) {
            setState(() {
              _currentIndex = index;
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Coming soon!'),
                duration: const Duration(seconds: 2),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_soccer),
            label: 'Matches',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.recommend), // Icono que represente Recommended Bets
            label: 'Recommended',
          ),
            BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),          
            label: 'My Bets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            label: 'Marketplace',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
