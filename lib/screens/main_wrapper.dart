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
              onViewMoreTapped: () {
                setState(() {
                  _currentCategory = 'Descubrir';
                  _selectedIndex = 1;
                });
              },
            )
          : _selectedIndex == 1
              ? DiscoveryScreenWrapper(categoryName: _currentCategory)
              : const WatchlistScreen(),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 4, right: 4),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
                if (index == 1) {
                  _currentCategory = 'Descubrir';
                }
              });
            },
            backgroundColor: const Color(0xFF1E1E1E).withValues(alpha: 0.95),
            elevation: 10,
            selectedItemColor: Colors.greenAccent,
            unselectedItemColor: Colors.grey,
            showSelectedLabels: true,
            showUnselectedLabels: false,
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                icon: Icon(
                  _selectedIndex == 0 ? Icons.home_rounded : Icons.home_outlined,
                  size: 22,
                ),
                label: 'Menú',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  _selectedIndex == 1 ? Icons.local_movies_rounded : Icons.local_movies_outlined,
                  size: 22,
                ),
                label: 'Descubrir',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  _selectedIndex == 2 ? Icons.bookmark_rounded : Icons.bookmark_outline,
                  size: 22,
                ),
                label: 'Mi Lista',
              ),
            ],
          ),
        ),
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