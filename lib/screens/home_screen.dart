import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import '../widgets/category_card.dart';
import '../widgets/movie_search_delegate.dart';
import '../widgets/animations.dart';
import '../services/tmdb_service.dart';

class HomeScreen extends StatefulWidget {
  final Function(String)? onCategorySelected;
  
  const HomeScreen({super.key, this.onCategorySelected});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Map<String, dynamic>>> _genresFuture;
  bool _hasConnection = true;
  late Connectivity _connectivity;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  late Timer _connectivityTimer;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _connectivity = Connectivity();
    
    // Verificar conexión inicial
    _checkConnection();
    
    // Escuchar cambios de conectividad
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        setState(() => _hasConnection = true);
      } else {
        setState(() => _hasConnection = false);
      }
    });
    
    // Verificar conexión cada 5 segundos
    _startConnectivityTimer();
    
    _genresFuture = TMDBService.getGenres();
  }

  void _startConnectivityTimer() {
    _connectivityTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) {
        _checkConnection();
      }
    });
  }

  Future<void> _checkConnection() async {
    final result = await _connectivity.checkConnectivity();
    final hasConnection = result != ConnectivityResult.none;
    
    if (mounted && hasConnection != _hasConnection) {
      setState(() {
        _hasConnection = hasConnection;
      });
    }
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _connectivitySubscription.cancel();
    _connectivityTimer.cancel();
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
      body: _hasConnection 
          ? _buildCategoriesView()
          : _buildNoConnectionView(),
    );
  }

  Widget _buildNoConnectionView() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          backgroundColor: const Color(0xFF121212),
          centerTitle: true,
          elevation: 2,
          title: const Text(
            'FLICK',
            style: TextStyle(
              letterSpacing: 4,
              fontWeight: FontWeight.bold,
              color: Colors.greenAccent,
              fontSize: 20,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            color: const Color(0xFF121212),
            height: MediaQuery.of(context).size.height - kToolbarHeight - 100,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.wifi_off,
                        size: 80,
                        color: Colors.orange[600],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Sin conexión a internet',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Estamos intentando reconectarnos...\nVerificando cada 5 segundos',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.orange.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.orange[600],
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Verifica tu conexión WiFi o datos',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: 200,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _checkConnection();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reintentar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesView() {
    return CustomScrollView(
      slivers: [
        // AppBar mejorado
        SliverAppBar(
          floating: true,
          backgroundColor: const Color(0xFF121212),
          centerTitle: true,
          elevation: 2,
          title: AnimatedEntrance(
            child: const Text(
              'FLICK',
              style: TextStyle(
                letterSpacing: 4,
                fontWeight: FontWeight.bold,
                color: Colors.greenAccent,
                fontSize: 20,
              ),
            ),
          ),
        ),

        // Contenido principal con animaciones
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Buscador mejorado con efecto
                GestureDetector(
                    onTap: () => showSearch(context: context, delegate: MovieSearchDelegate()),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.greenAccent.withValues(alpha: 0.2),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.greenAccent.withValues(alpha: 0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.search, color: Colors.greenAccent, size: 22),
                          SizedBox(width: 12),
                          Text(
                            '¿Qué quieres ver hoy?',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 32),

                // Sección Categorías mejorada
                AnimatedEntrance(
                  delay: const Duration(milliseconds: 200),
                  child: const Text(
                    'Explora por Categoría',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),

        // Grid de categorías
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
                  (context, index) => AnimatedEntrance(
                    delay: Duration(milliseconds: 50 + (index * 10)),
                    child: CategoryCard(
                      name: _mapEnglishToSpanish(genres[index]['name']),
                      color: _getColorForGenre(_mapEnglishToSpanish(genres[index]['name'])),
                      gradientColors: _getGradientColorsForGenre(_mapEnglishToSpanish(genres[index]['name'])),
                      onTap: () {
                        if (widget.onCategorySelected != null) {
                          widget.onCategorySelected!(_mapEnglishToSpanish(genres[index]['name']));
                        }
                      },
                    ),
                  ),
                  childCount: genres.length,
                ),
              );
            },
          ),
        ),

        // Footer spacing
        const SliverToBoxAdapter(
          child: SizedBox(height: 40),
        ),
      ],
    );
  }
}