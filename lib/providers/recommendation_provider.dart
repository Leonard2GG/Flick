import '../services/recommendation_service.dart';
import '../models/movie.dart';

/// Provider para manejar recomendaciones
class RecommendationProvider {
  final RecommendationService _service = RecommendationService();

  /// Inicializa el servicio de recomendaciones
  Future<void> initialize() async {
    await _service.initialize();
  }

  /// Obtiene recomendaciones personalizadas
  Future<List<Movie>> getRecommendations(
    List<Movie> availableMovies, {
    int maxRecommendations = 10,
  }) async {
    return await _service.generateRecommendations(
      availableMovies,
      maxRecommendations: maxRecommendations,
    );
  }

  /// Obtiene películas similares a una específica
  Future<List<Movie>> getSimilarMovies(
    Movie movie,
    List<Movie> availableMovies, {
    int maxSimilar = 5,
  }) async {
    return await _service.getMovieSimilarRecommendations(
      movie,
      availableMovies,
      maxRecommendations: maxSimilar,
    );
  }

  /// Registra una película como visualizada
  Future<void> recordMovieViewed({
    required String movieId,
    required String category,
    required double rating,
    required int watchDurationSeconds,
    required double completionPercentage,
  }) async {
    await _service.recordMovieViewed(
      movieId: movieId,
      category: category,
      rating: rating,
      watchDurationSeconds: watchDurationSeconds,
      completionPercentage: completionPercentage,
    );
  }

  /// Obtiene estadísticas del usuario
  Map<String, dynamic> getUserStatistics() {
    return _service.getUserStatistics();
  }

  /// Obtiene géneros favoritos del usuario
  List<String> get favoriteGenres => _service.favoriteGenres;

  /// Obtiene promedio de rating del usuario
  double get averageUserRating => _service.averageUserRating;

  /// Limpia recomendaciones
  void clearRecommendations() {
    _service.clearRecommendations();
  }
}
