import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'watchlist_screen.dart';
import 'discovery_screen.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const DiscoveryScreenWrapper(),
    const WatchlistScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        backgroundColor: const Color(0xFF121212),
        selectedItemColor: Colors.greenAccent,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Menú'),
          BottomNavigationBarItem(icon: Icon(Icons.local_movies), label: 'Descubrir'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Mi Lista'),
        ],
      ),
    );
  }
}

// Wrapper para la pantalla de descubrimiento
class DiscoveryScreenWrapper extends StatelessWidget {
  const DiscoveryScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return const DiscoveryScreen(categoryName: 'Descubrir');
  }
}