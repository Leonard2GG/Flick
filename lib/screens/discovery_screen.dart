import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/movie.dart';
import '../providers/movie_provider.dart';
import '../services/tmdb_service.dart';
import '../widgets/cached_image_loader.dart';

enum CardAction { watchLater, discard }

class DiscoveryScreen extends StatefulWidget {
  final String categoryName;
  final bool fromSearch;

  const DiscoveryScreen({
    Key? key,
    required this.categoryName,
    this.fromSearch = false,
  }) : super(key: key);

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late PageController _pageController;
  int _currentIndex = 0;
  Offset _dragOffset = Offset.zero;
  CardAction? _currentAction;
  List<Movie> _allMovies = [];
  List<Movie> _filteredMovies = [];
  int _currentPage = 1;
  bool _isLoadingMore = false;
  final Map<String, int> _genreNameToId = {
    'Acción': 28,
    'Aventura': 12,
    'Animación': 16,
    'Comedia': 35,
    'Crimen': 80,
    'Documental': 99,
    'Drama': 18,
    'Familia': 10751,
    'Fantasía': 14,
    'Historia': 36,
    'Terror': 27,
    'Música': 10402,
    'Misterio': 9648,
    'Romance': 10749,
    'Sci-Fi': 878,
    'Televisión': 10770,
    'Thriller': 53,
    'Guerra': 10752,
    'Western': 37,
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _pageController = PageController(
      viewportFraction: 1.0,
    );
    _pageController.addListener(_onPageChanged);
    _currentPage = 1;
    _loadMoreMovies();
  }

  void _onPageChanged() {
    // Cargar más películas cuando estamos cerca del final
    if (_pageController.page != null) {
      int nextPageIndex = _pageController.page!.round() + 1;
      if (nextPageIndex >= _filteredMovies.length - 3 && !_isLoadingMore) {
        _loadMoreMovies();
      }
    }
  }

  Future<void> _loadMoreMovies() async {
    if (_isLoadingMore) return;
    setState(() => _isLoadingMore = true);

    try {
      List<Movie> newMovies = [];

      // Si la categoría es un género conocido, usar páginas aleatorias para variar resultados
      if (_genreNameToId.containsKey(widget.categoryName)) {
        newMovies = await TMDBService.getRandomMoviesByGenre(
          _genreNameToId[widget.categoryName]!,
        );
      } else if (widget.categoryName == 'Descubrir') {
        // Si es "Descubrir", obtener películas populares de una página aleatoria
        newMovies = await TMDBService.getRandomPopularMovies();
      } else {
        // Si es una búsqueda de texto, buscar por nombre (esto seguirá siendo determinista por query)
        newMovies = await TMDBService.searchMovies(widget.categoryName, page: _currentPage);
      }

      setState(() {
        _allMovies.addAll(newMovies);
        _filteredMovies = _filterMoviesByName(_allMovies);
        _currentPage++;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() => _isLoadingMore = false);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    super.dispose();
  }

 

  List<Movie> _filterMoviesByName(List<Movie> movies) {
    // Filtrar películas que no se llamen exactamente como la categoría
    return movies.where((movie) {
      final movieTitle = movie.title.toLowerCase().trim();
      final categoryName = widget.categoryName.toLowerCase().trim();
      return movieTitle != categoryName;
    }).toList();
  }

  void _handleSwipeAction(CardAction action) {
    final movie = _filteredMovies[_currentIndex];
    final movieProvider = context.read<MovieProvider>();

    if (action == CardAction.watchLater) {
      movieProvider.addToWatchlist(movie);
    } else if (action == CardAction.discard) {
      // Película descartada
    }

    // Registrar en historial
    movieProvider.addToHistory(movie);

    // Pasar a la siguiente película
    if (_currentIndex < _filteredMovies.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Si no hay más películas, cargar más automáticamente
      _loadMoreMovies();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _filteredMovies.isEmpty && _currentPage == 1
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Cargando películas...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                // PageView con diseño fullscreen
                PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                      _dragOffset = Offset.zero;
                      _currentAction = null;
                    });
                  },
                  itemCount: _filteredMovies.length,
                  itemBuilder: (context, index) {
                    return _buildFullscreenMovieCard(_filteredMovies[index]);
                  },
                ),
                // Indicador de carga cuando se cargan más películas
                if (_isLoadingMore)
                  Positioned(
                    bottom: 120,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          // Botón de retroceso superpuesto si viene desde búsqueda
          if (widget.fromSearch)
            Positioned(
              top: 20,
              left: 10,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chevron_left,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFullscreenMovieCard(Movie movie) {
    return Consumer<MovieProvider>(
      builder: (context, movieProvider, child) {
        final isInWatchlist = movieProvider.isInWatchlist(movie.id);
        final isFavorite = movieProvider.isFavorite(movie.id);

        return GestureDetector(
          onHorizontalDragUpdate: (details) {
            if (_filteredMovies.isNotEmpty) {
              setState(() {
                _dragOffset += Offset(details.delta.dx, 0);
                if (_dragOffset.dx < -50) {
                  _currentAction = CardAction.watchLater;
                } else if (_dragOffset.dx > 50) {
                  _currentAction = CardAction.discard;
                } else {
                  _currentAction = null;
                }
              });
            }
          },
          onHorizontalDragEnd: (details) {
            if (_filteredMovies.isNotEmpty) {
              if (_dragOffset.dx < -100) {
                _handleSwipeAction(CardAction.watchLater);
              } else if (_dragOffset.dx > 100) {
                _handleSwipeAction(CardAction.discard);
              } else {
                setState(() {
                  _dragOffset = Offset.zero;
                  _currentAction = null;
                });
              }
            }
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Imagen de fondo fullscreen con cache
              CachedImageLoader(
                imageUrl: movie.imageUrl,
                fit: BoxFit.cover,
              ),

          // Gradiente superior
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.center,
                colors: [Colors.black54, Colors.transparent],
              ),
            ),
          ),

          // Gradiente inferior (más oscuro)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.center,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black87],
              ),
            ),
          ),

          // INDICADORES DE SWIPE (Verde/Rojo) - Dinámicos
          if (_currentAction == CardAction.watchLater)
            Opacity(
              opacity: 0.7,
              child: Container(
                color: Colors.green.withValues(alpha: 0.6),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite, color: Colors.white, size: 80),
                      SizedBox(height: 20),
                      Text(
                        'VER MÁS TARDE',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          if (_currentAction == CardAction.discard)
            Opacity(
              opacity: 0.7,
              child: Container(
                color: Colors.red.withValues(alpha: 0.6),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.close, color: Colors.white, size: 80),
                      SizedBox(height: 20),
                      Text(
                        'DESCARTAR',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Información en la parte inferior
          Positioned(
            bottom: 120,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie.title,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.yellow[600],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star,
                              color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            movie.rating,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      movie.year,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.greenAccent.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        movie.category,
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Botones de favorito, compartir y estado watchlist
                Row(
                  children: [
                    // Botón de favorito
                    GestureDetector(
                      onTap: () {
                        movieProvider.toggleFavorite(movie.id);
                      },
                      child: AnimatedScale(
                        scale: isFavorite ? 1.1 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isFavorite
                                ? Colors.redAccent.withValues(alpha: 0.8)
                                : Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Botón de compartir
                    GestureDetector(
                      onTap: () {
                        Share.share(
                          '${movie.title}\n⭐ ${movie.rating}\n📅 ${movie.year}\n\n${movie.description}',
                          subject: 'Mira esta película: ${movie.title}',
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.share,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Indicador de watchlist
                    if (isInWatchlist)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.greenAccent.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.check, color: Colors.black, size: 14),
                            SizedBox(width: 4),
                            Text(
                              'En mi lista',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Desliza para más info ▲',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Panel deslizable hacia arriba
          _buildDetailsSheet(movie),
        ],
      ),
    );
      },
    );
  }

  Widget _buildDetailsSheet(Movie movie) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.05,
      minChildSize: 0.05,
      maxChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF121212),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    movie.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          movie.category,
                          style: TextStyle(
                            color: Colors.blue[800],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            movie.rating,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        movie.year,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Descripción',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    movie.description,
                    style: TextStyle(
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Reparto',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Cargar reparto desde TMDB
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: TMDBService.getMovieCast(movie.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.greenAccent,
                            ),
                          ),
                        );
                      }

                      if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Text(
                            'Sin información de reparto',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        );
                      }

                      final castList = snapshot.data!;
                      return GridView.count(
                        crossAxisCount: 3,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        children: castList.map((actor) {
                          final profilePath = actor['profilePath'] ?? '';
                          final hasImage = profilePath.isNotEmpty;

                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              hasImage
                                  ? ClipOval(
                                      child: CachedImageLoader(
                                        imageUrl: profilePath,
                                        width: 70,
                                        height: 70,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Container(
                                      width: 70,
                                      height: 70,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.greenAccent.withValues(
                                          alpha: 0.3,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.person,
                                        size: 35,
                                        color: Colors.greenAccent,
                                      ),
                                    ),
                              const SizedBox(height: 8),
                              Text(
                                actor['name']!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}