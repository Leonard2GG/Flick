import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import '../widgets/movie_search_delegate.dart';
import '../widgets/animations.dart';
import '../widgets/movie_sections_widget.dart';
import '../widgets/categories_grid_widget.dart';
import '../services/category_service.dart';
import '../models/movie.dart';

class HomeScreen extends StatefulWidget {
  final Function(String)? onCategorySelected;
  final VoidCallback? onViewMoreTapped;
  
  const HomeScreen({
    super.key, 
    this.onCategorySelected,
    this.onViewMoreTapped,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Movie>> _upcomingMoviesFuture;
  late Future<List<Movie>> _recommendedMoviesFuture;
  late Future<List<Map<String, dynamic>>> _categoriesFuture;
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
    
    _upcomingMoviesFuture = CategoryService.getUpcomingMovies();
    _recommendedMoviesFuture = CategoryService.getPopularMovies();
    _categoriesFuture = CategoryService.getAllCategories();
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
                const SizedBox(height: 16),

                // 1. PRÓXIMOS ESTRENOS
                FutureBuilder<List<Movie>>(
                  future: _upcomingMoviesFuture,
                  builder: (context, snapshot) {
                    return UpcomingMoviesCard(
                      upcomingMovies: snapshot.data ?? [],
                      isLoading: snapshot.connectionState == ConnectionState.waiting,
                      onViewMoreTapped: widget.onViewMoreTapped,
                    );
                  },
                ),
                const SizedBox(height: 16),

                // 2. RECOMENDACIONES DE LA APP
                FutureBuilder<List<Movie>>(
                  future: _recommendedMoviesFuture,
                  builder: (context, snapshot) {
                    return AppRecommendedMoviesCard(
                      recommendedMovies: snapshot.data ?? [],
                      isLoading: snapshot.connectionState == ConnectionState.waiting,
                      onViewMoreTapped: widget.onViewMoreTapped,
                    );
                  },
                ),
                const SizedBox(height: 16),

                // 3. TODAS LAS CATEGORÍAS
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _categoriesFuture,
                  builder: (context, snapshot) {
                    return CategoriesGridWidget(
                      categories: snapshot.data ?? [],
                      onCategoryTap: (categoryId, categoryName) {
                        if (widget.onCategorySelected != null) {
                          widget.onCategorySelected!(categoryName);
                        }
                      },
                    );
                  },
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}