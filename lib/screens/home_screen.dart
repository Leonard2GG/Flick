import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/category_card.dart';
import '../widgets/movie_search_delegate.dart';

class HomeScreen extends StatefulWidget {
  final Function(String)? onCategorySelected;
  
  const HomeScreen({super.key, this.onCategorySelected});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> categories = [
      {'name': 'Acción', 'color': Colors.orange},
      {'name': 'Comedia', 'color': Colors.blue},
      {'name': 'Terror', 'color': Colors.purple},
      {'name': 'Drama', 'color': Colors.red},
      {'name': 'Sci-Fi', 'color': Colors.teal},
      {'name': 'Documentales', 'color': Colors.green},
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            backgroundColor: const Color(0xFF121212),
            centerTitle: true,
            title: const Text('FLICK', style: TextStyle(letterSpacing: 4, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Buscador Visual (Caja de texto)
                  GestureDetector(
                    onTap: () => showSearch(context: context, delegate: MovieSearchDelegate()),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.search, color: Colors.grey),
                          SizedBox(width: 10),
                          Text('¿Qué quieres ver hoy?', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Categorías', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 15,
                crossAxisSpacing: 15,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => CategoryCard(
                  name: categories[index]['name'],
                  color: categories[index]['color'],
                  onTap: () {
                    if (widget.onCategorySelected != null) {
                      widget.onCategorySelected!(categories[index]['name']);
                    }
                  },
                ),
                childCount: categories.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}