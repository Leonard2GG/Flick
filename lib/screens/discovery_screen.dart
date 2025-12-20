import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/movie.dart';
import '../providers/movie_provider.dart';

enum CardAction { watchLater, discard }

class DiscoveryScreen extends StatefulWidget {
  final String categoryName;

  const DiscoveryScreen({
    Key? key,
    required this.categoryName,
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

  final List<Movie> _allMovies = [
    Movie(
      id: '1',
      title: 'Blade Runner 2049',
      imageUrl: 'https://picsum.photos/300/400?random=1',
      category: 'Sci-Fi',
      rating: '8.0',
      year: '2017',
      description: 'Un nuevo cazarrecompensas descubre un secreto perdido.',
      cast: ['Ryan Gosling', 'Harrison Ford'],
    ),
    Movie(
      id: '2',
      title: 'Dune',
      imageUrl: 'https://picsum.photos/300/400?random=2',
      category: 'Sci-Fi',
      rating: '8.0',
      year: '2021',
      description: 'La épica aventura en el planeta Arrakis.',
      cast: ['Timothée Chalamet', 'Zendaya'],
    ),
    Movie(
      id: '3',
      title: 'Forrest Gump',
      imageUrl: 'https://picsum.photos/300/400?random=3',
      category: 'Drama',
      rating: '8.8',
      year: '1994',
      description: 'Un hombre con discapacidad intelectual logra cosas extraordinarias.',
      cast: ['Tom Hanks', 'Sally Field'],
    ),
    Movie(
      id: '4',
      title: 'The Shawshank Redemption',
      imageUrl: 'https://picsum.photos/300/400?random=4',
      category: 'Drama',
      rating: '9.3',
      year: '1994',
      description: 'La historia de amistad y esperanza en prisión.',
      cast: ['Tim Robbins', 'Morgan Freeman'],
    ),
    Movie(
      id: '5',
      title: 'Mad Max: Fury Road',
      imageUrl: 'https://picsum.photos/300/400?random=5',
      category: 'Acción',
      rating: '8.1',
      year: '2015',
      description: 'Una persecución épica en un desierto post-apocalíptico.',
      cast: ['Tom Hardy', 'Charlize Theron'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _pageController = PageController();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  List<Movie> _filterMoviesByCategory() {
    // Si la categoría es "Descubrir", mostrar todas las películas
    if (widget.categoryName == 'Descubrir') {
      return _allMovies;
    }
    return _allMovies
        .where((movie) => movie.category == widget.categoryName)
        .toList();
  }

  void _handleSwipeAction(CardAction action) {
    final filteredMovies = _filterMoviesByCategory();
    final movie = filteredMovies[_currentIndex];

    if (action == CardAction.watchLater) {
      context.read<MovieProvider>().addToWatchlist(movie);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${movie.title} agregada a tu lista'),
          duration: const Duration(milliseconds: 800),
          backgroundColor: Colors.green[700],
        ),
      );
    } else if (action == CardAction.discard) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${movie.title} descartada'),
          duration: const Duration(milliseconds: 600),
          backgroundColor: Colors.red[700],
        ),
      );
    }

    if (_currentIndex < filteredMovies.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay más películas en esta categoría')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredMovies = _filterMoviesByCategory();

    if (filteredMovies.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.categoryName),
        ),
        body: Center(
          child: Text('No hay películas en la categoría ${widget.categoryName}'),
        ),
      );
    }

    return Scaffold(
      body: Stack(
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
            itemCount: filteredMovies.length,
            itemBuilder: (context, index) {
              return _buildFullscreenMovieCard(filteredMovies[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFullscreenMovieCard(Movie movie) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        setState(() {
          _dragOffset += Offset(details.delta.dx, 0);
          if (_dragOffset.dx > 50) {
            _currentAction = CardAction.watchLater;
          } else if (_dragOffset.dx < -50) {
            _currentAction = CardAction.discard;
          } else {
            _currentAction = null;
          }
        });
      },
      onHorizontalDragEnd: (details) {
        if (_dragOffset.dx > 100) {
          _handleSwipeAction(CardAction.watchLater);
        } else if (_dragOffset.dx < -100) {
          _handleSwipeAction(CardAction.discard);
        } else {
          setState(() {
            _dragOffset = Offset.zero;
            _currentAction = null;
          });
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Imagen de fondo fullscreen
          Image.network(
            movie.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[900],
                child: const Center(
                  child: Icon(Icons.movie, size: 80, color: Colors.grey),
                ),
              );
            },
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
                  const SizedBox(height: 8),
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: movie.cast.map((actor) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.greenAccent.withValues(alpha: 0.3),
                            ),
                            child: const Icon(
                              Icons.person,
                              size: 35,
                              color: Colors.greenAccent,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            actor,
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