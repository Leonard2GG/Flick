import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import '../widgets/cached_image_loader.dart';
import 'movie_detail_screen.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  late ScrollController _scrollController;
  int _minYearFilter = 2000;
  int _maxYearFilter = 2025;
  double _minRatingFilter = 0.0;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MI LISTA',
          style: TextStyle(letterSpacing: 4, fontWeight: FontWeight.bold, color: Colors.greenAccent),
        ),
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _showFilters = !_showFilters;
                  });
                },
                child: Icon(
                  _showFilters ? Icons.filter_alt : Icons.filter_alt_outlined,
                  color: _showFilters ? Colors.greenAccent : Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Consumer<MovieProvider>(
        builder: (context, movieProvider, child) {
          final movies = _showFilters
              ? movieProvider.getFilteredWatchlist(
                  minYear: _minYearFilter,
                  maxYear: _maxYearFilter,
                  minRating: _minRatingFilter,
                )
              : movieProvider.watchlist;

          if (movies.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.movie_filter, size: 80, color: Colors.grey[800]),
                  const SizedBox(height: 16),
                  const Text(
                    'Tu lista está vacía',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '¡Empieza a deslizar para añadir!',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Filtros expandibles
              if (_showFilters) _buildFilterPanel(movieProvider),
              // Lista de películas con lazy loading
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: movies.length,
                  itemBuilder: (context, index) {
                    final movie = movies[index];
                    final isFavorite = movieProvider.isFavorite(movie.id);

                    return Dismissible(
                      key: Key(movie.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) {
                        movieProvider.removeFromWatchlist(movie);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        height: 120,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            // Miniatura con cache
                            ClipRRect(
                              borderRadius: const BorderRadius.horizontal(
                                  left: Radius.circular(15)),
                              child: CachedImageLoader(
                                imageUrl: movie.imageUrl,
                                width: 90,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                            ),
                            // Detalles
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            movie.title,
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (isFavorite)
                                          const Padding(
                                            padding: EdgeInsets.only(left: 8),
                                            child: Icon(
                                              Icons.favorite,
                                              color: Colors.redAccent,
                                              size: 16,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${movie.year} • ⭐ ${movie.rating}",
                                      style: const TextStyle(
                                          color: Colors.greenAccent,
                                          fontSize: 14),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      movie.category,
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 12,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        MovieDetailScreen(movie: movie),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: Icon(Icons.chevron_right,
                                    color: Colors.greenAccent, size: 28),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterPanel(MovieProvider movieProvider) {
    return Container(
      color: const Color(0xFF1E1E1E),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filtros',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.greenAccent,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Año: 2000 - 2025',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 8),
                    RangeSlider(
                      values: RangeValues(
                          _minYearFilter.toDouble(), _maxYearFilter.toDouble()),
                      min: 2000,
                      max: 2025,
                      activeColor: Colors.greenAccent,
                      inactiveColor: Colors.grey[800],
                      onChanged: (RangeValues values) {
                        setState(() {
                          _minYearFilter = values.start.toInt();
                          _maxYearFilter = values.end.toInt();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Rating mínimo: ',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
              Slider(
                value: _minRatingFilter,
                min: 0,
                max: 10,
                activeColor: Colors.greenAccent,
                inactiveColor: Colors.grey[800],
                onChanged: (value) {
                  setState(() {
                    _minRatingFilter = value;
                  });
                },
              ),
              Text('${_minRatingFilter.toStringAsFixed(1)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.greenAccent,
                  )),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _minYearFilter = 2000;
                  _maxYearFilter = 2025;
                  _minRatingFilter = 0.0;
                  _showFilters = false;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
              ),
              child: const Text(
                'Limpiar filtros',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
                onDismissed: (direction) {
                  movieProvider.removeFromWatchlist(movie);
                },
                child: Container(
                  margin: EdgeInsets.only(bottom: 16),
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      // Miniatura de la película
                      ClipRRect(
                        borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(15)),
                        child: Image.network(
                          movie.imageUrl,
                          width: 90,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Detalles
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                movie.title,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${movie.year} • ★ ${movie.rating}",
                                style: const TextStyle(
                                    color: Colors.greenAccent, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  MovieDetailScreen(movie: movie),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: Icon(Icons.chevron_right,
                              color: Colors.greenAccent, size: 28),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}