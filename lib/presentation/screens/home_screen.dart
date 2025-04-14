import 'package:flutter/material.dart';
import 'matches_view.dart';
import "recommended_bet_screen.dart"; // Asegúrate de importar tu pantalla de RecommendedBets

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
    const Placeholder(), // Índice 2: Marketplace (Coming soon)
    const Placeholder(), // Índice 3: Profile (Coming soon)
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
          // Solo los índices 0 y 1 navegan a una pantalla real.
          if (index == 0 || index == 1) {
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
