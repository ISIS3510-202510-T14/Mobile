import 'package:flutter/material.dart';
import 'matches_view.dart';

// EJEMPLO DE BOTTOM NAV BAR CON 4 PESTAÑAS, SOLO LA PRIMERA ES FUNCIONAL
class HomeNav extends StatefulWidget {
  const HomeNav({Key? key}) : super(key: key);

  @override
  State<HomeNav> createState() => _HomeNavState();
}

class _HomeNavState extends State<HomeNav> {
  int _currentIndex = 0;

  // Solo la primera pantalla (Matches) es real, las demás se quedan con la misma vista
  final List<Widget> _screens = [
    const MatchesView(), // tu pantalla de partidos
    // Las demás apuntan también a MatchesView o a un widget placeholder si quisieras
    // pero en este ejemplo no se van a mostrar gracias al onTap
    const MatchesView(),
    const MatchesView(),
    const MatchesView(),
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
          if (index == 0) {
            // Solo la primera pestaña (Matches) navega
            setState(() {
              _currentIndex = 0;
            });
          } else {
            // Las demás muestran un SnackBar con "Coming soon"
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Coming soon!'),
                duration: Duration(seconds: 2),
                backgroundColor: Theme.of(context).colorScheme.primary
              ),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.adjust), // Ícono aproximado de "diana"
            label: 'Matches',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            label: 'Marketplace',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star_border),
            label: 'Favorites',
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


