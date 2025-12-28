import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recommendation_provider.dart';
import '../models/movie.dart';
import '../screens/movie_detail_screen.dart';
import 'cached_image_loader.dart';

/// Widget que muestra recomendaciones personalizadas en la home screen
class PersonalizedRecommendationsWidget extends StatefulWidget {
  final List<Movie> availableMovies;
  final String title;

  const PersonalizedRecommendationsWidget({
    super.key,
    required this.availableMovies,
    this.title = 'Recomendado para ti',
  });

  @override
  State<PersonalizedRecommendationsWidget> createState() =>
      _PersonalizedRecommendationsWidgetState();
}

class _PersonalizedRecommendationsWidgetState
    extends State<PersonalizedRecommendationsWidget> {
  List<Movie> _recommendations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    try {
      final recommendationProvider =
          Provider.of<RecommendationProvider>(context, listen: false);

      final recommendations =
          await recommendationProvider.getRecommendations(
        widget.availableMovies,
        maxRecommendations: 5,
      );

      if (mounted) {
        setState(() {
          _recommendations = recommendations;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error cargando recomendaciones: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ShimmerLoader(),
            ),
          ],
        ),
      );
    }

    if (_recommendations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Icon(
                  Icons.auto_awesome,
                  color: Colors.greenAccent,
                  size: 20,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _recommendations.length,
              itemBuilder: (context, index) {
                final movie = _recommendations[index];
                return _RecommendationCard(movie: movie);
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget para mostrar una película recomendada
class _RecommendationCard extends StatelessWidget {
  final Movie movie;

  const _RecommendationCard({required this.movie});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieDetailScreen(movie: movie),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  CachedImageLoader(
                    imageUrl: movie.imageUrl,
                    height: 150,
                    width: 110,
                  ),
                  // Overlay con info
                  Container(
                    height: 150,
                    width: 110,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black87,
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                movie.rating,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 110,
              child: Text(
                movie.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget de carga shimmer
class ShimmerLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 150,
                  width: 110,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 12,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Widget para mostrar películas similares en detalles
class SimilarMoviesWidget extends StatefulWidget {
  final Movie sourceMovie;
  final List<Movie> availableMovies;

  const SimilarMoviesWidget({
    super.key,
    required this.sourceMovie,
    required this.availableMovies,
  });

  @override
  State<SimilarMoviesWidget> createState() => _SimilarMoviesWidgetState();
}

class _SimilarMoviesWidgetState extends State<SimilarMoviesWidget> {
  List<Movie> _similarMovies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSimilarMovies();
  }

  Future<void> _loadSimilarMovies() async {
    try {
      final recommendationProvider =
          Provider.of<RecommendationProvider>(context, listen: false);

      final similar = await recommendationProvider.getSimilarMovies(
        widget.sourceMovie,
        widget.availableMovies,
        maxSimilar: 5,
      );

      if (mounted) {
        setState(() {
          _similarMovies = similar;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error cargando películas similares: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _similarMovies.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Text(
              'Películas Similares',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _similarMovies.length,
              itemBuilder: (context, index) {
                final movie = _similarMovies[index];
                return _RecommendationCard(movie: movie);
              },
            ),
          ),
        ],
      ),
    );
  }
}
