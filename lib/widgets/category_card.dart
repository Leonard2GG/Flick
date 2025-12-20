import 'package:flutter/material.dart';
import '../screens/discovery_screen.dart'; // Importa la nueva pantalla

class CategoryCard extends StatelessWidget {
  final String name;
  final Color color;

  const CategoryCard({super.key, required this.name, required this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // NAVEGACIÓN AÑADIDA
        Navigator.push(
          context, 
          MaterialPageRoute(builder: (context) => DiscoveryScreen(categoryName: name))
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.8), color],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              bottom: 12,
              left: 12,
              child: Text(name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}