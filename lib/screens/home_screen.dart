import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/category_card.dart';
import '../widgets/movie_search_delegate.dart';
import '../services/tmdb_service.dart';

class HomeScreen extends StatefulWidget {
  final Function(String)? onCategorySelected;
  
  const HomeScreen({super.key, this.onCategorySelected});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Map<String, dynamic>>> _genresFuture;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _genresFuture = TMDBService.getGenres();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    super.dispose();
  }

  Color _getColorForGenre(String genreName) {
    final colorMap = {
      'Acción': Colors.orange,
      'Comedia': Colors.blue,
      'Terror': Colors.purple,
      'Drama': Colors.red,
      'Sci-Fi': Colors.teal,
      'Documentales': Colors.green,
      'Aventura': Colors.amber,
      'Animación': Colors.pink,
      'Familia': Colors.cyan,
      'Fantasía': Colors.deepPurple,
      'Thriller': Colors.indigo,
      'Romance': Colors.pink,
    };
    return colorMap[genreName] ?? Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
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
            sliver: FutureBuilder<List<Map<String, dynamic>>>(
              future: _genresFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(color: Colors.greenAccent),
                      ),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Text('Error al cargar categorías: ${snapshot.error}'),
                    ),
                  );
                }

                final genres = snapshot.data ?? [];
                return SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 15,
                    crossAxisSpacing: 15,
                    childAspectRatio: 1.5,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => CategoryCard(
                      name: genres[index]['name'],
                      color: _getColorForGenre(genres[index]['name']),
                      onTap: () {
                        if (widget.onCategorySelected != null) {
                          widget.onCategorySelected!(genres[index]['name']);
                        }
                      },
                    ),
                    childCount: genres.length,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}