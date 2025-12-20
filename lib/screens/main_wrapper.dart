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
  String _currentCategory = 'Descubrir';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _selectedIndex == 0
          ? HomeScreen(
              onCategorySelected: (category) {
                setState(() {
                  _currentCategory = category;
                  _selectedIndex = 1;
                });
              },
            )
          : _selectedIndex == 1
              ? DiscoveryScreenWrapper(categoryName: _currentCategory)
              : const WatchlistScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            if (index == 1) {
              _currentCategory = 'Descubrir';
            }
          });
        },
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
  final String categoryName;
  const DiscoveryScreenWrapper({super.key, this.categoryName = 'Descubrir'});

  @override
  Widget build(BuildContext context) {
    return DiscoveryScreen(categoryName: categoryName);
  }
}