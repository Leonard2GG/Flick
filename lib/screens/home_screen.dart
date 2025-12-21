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
      'Acción': Colors.red,
      'Comedia': Colors.blue,
      'Terror': Colors.purple,
      'Drama': Colors.deepOrange,
      'Sci-Fi': Colors.cyan,
      'Documental': Colors.green,
      'Aventura': Colors.amber,
      'Animación': Colors.pink,
      'Familia': Colors.lightBlue,
      'Fantasía': Colors.deepPurple,
      'Thriller': Colors.indigo,
      'Romance': Colors.pinkAccent,
      'Crimen': Colors.blueGrey,
      'Historia': Colors.brown,
      'Música': Colors.orange,
      'Misterio': Colors.purpleAccent,
      'Guerra': Colors.grey,
      'Western': Colors.orange,
      'Televisión': Colors.teal,
    };
    return colorMap[genreName] ?? Colors.grey;
  }

  List<Color> _getGradientColorsForGenre(String genreName) {
    final gradientMap = {
      'Acción': [Colors.red.shade700, Colors.red.shade400],
      'Comedia': [Colors.blue.shade700, Colors.blue.shade400],
      'Terror': [Colors.purple.shade900, Colors.purple.shade600],
      'Drama': [Colors.deepOrange.shade700, Colors.deepOrange.shade400],
      'Sci-Fi': [Colors.cyan.shade700, Colors.cyan.shade400],
      'Documental': [Colors.green.shade700, Colors.green.shade400],
      'Aventura': [Colors.amber.shade700, Colors.amber.shade400],
      'Animación': [Colors.pink.shade700, Colors.pink.shade400],
      'Familia': [Colors.lightBlue.shade700, Colors.lightBlue.shade400],
      'Fantasía': [Colors.deepPurple.shade900, Colors.deepPurple.shade600],
      'Thriller': [Colors.indigo.shade700, Colors.indigo.shade400],
      'Romance': [Colors.pinkAccent.shade700, Colors.pinkAccent.shade400],
      'Crimen': [Colors.blueGrey.shade700, Colors.blueGrey.shade400],
      'Historia': [Colors.brown.shade700, Colors.brown.shade400],
      'Música': [Colors.orange.shade700, Colors.orange.shade400],
      'Misterio': [Colors.purpleAccent.shade700, Colors.purpleAccent.shade400],
      'Guerra': [Colors.grey.shade700, Colors.grey.shade400],
      'Western': [Colors.orange.shade900, Colors.orange.shade600],
      'Televisión': [Colors.teal.shade700, Colors.teal.shade400],
    };
    return gradientMap[genreName] ?? [Colors.grey.shade700, Colors.grey.shade400];
  }
  
  // Mapear nombres de géneros desde TMDB (inglés) a nombres en español usados en la app
  String _mapEnglishToSpanish(String englishName) {
    const map = {
      'Action': 'Acción',
      'Adventure': 'Aventura',
      'Animation': 'Animación',
      'Comedy': 'Comedia',
      'Crime': 'Crimen',
      'Documentary': 'Documental',
      'Drama': 'Drama',
      'Family': 'Familia',
      'Fantasy': 'Fantasía',
      'History': 'Historia',
      'Horror': 'Terror',
      'Music': 'Música',
      'Mystery': 'Misterio',
      'Romance': 'Romance',
      'Science Fiction': 'Sci-Fi',
      'TV Movie': 'Televisión',
      'Thriller': 'Thriller',
      'War': 'Guerra',
      'Western': 'Western',
    };
    return map[englishName] ?? englishName;
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
                      name: _mapEnglishToSpanish(genres[index]['name']),
                      color: _getColorForGenre(_mapEnglishToSpanish(genres[index]['name'])),
                      gradientColors: _getGradientColorsForGenre(_mapEnglishToSpanish(genres[index]['name'])),
                      onTap: () {
                        if (widget.onCategorySelected != null) {
                          widget.onCategorySelected!(_mapEnglishToSpanish(genres[index]['name']));
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