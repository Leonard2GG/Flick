import 'dart:math';
import 'package:flutter/foundation.dart';
import 'intelligent_sync_service.dart';
import '../models/movie.dart';

/// Servicio de recomendaciones inteligente basado en Machine Learning
/// Analiza patrones de visualización y genera recomendaciones personalizadas
class RecommendationService extends ChangeNotifier {
  static final RecommendationService _instance =
      RecommendationService._internal();
  
  final IntelligentSyncService _syncService = IntelligentSyncService();
  
  List<Movie> _recommendations = [];
  final Map<String, double> _genrePreferences = {};
  List<String> _favoriteGenres = [];
  double _averageRating = 0;
  int _totalMoviesWatched = 0;

  factory RecommendationService() {
    return _instance;
  }

  RecommendationService._internal();

  /// Inicializa el servicio y carga patrones
  Future<void> initialize() async {
    await _syncService.initialize();
    await _loadViewingPatterns();
    notifyListeners();
  }

  /// Carga patrones de visualización del usuario
  Future<void> _loadViewingPatterns() async {
    try {
      final patterns = await _syncService.getViewingPatterns();
      
      if (patterns.isEmpty) {
        return;
      }

      // Calcular preferencias de género
      _genrePreferences.clear();
      double totalRating = 0;
      
      for (final pattern in patterns) {
        final category = pattern['category'] as String;
        final rating = (pattern['rating'] ?? 0) as num;
        final completionPercentage = (pattern['completion_percentage'] ?? 0) as num;

        // Ponderar por calificación y porcentaje de visualización
        final weight = (rating / 10) * (completionPercentage / 100);
        _genrePreferences[category] =
            (_genrePreferences[category] ?? 0) + weight;

        totalRating += rating;
        _totalMoviesWatched++;
      }

      _averageRating = _totalMoviesWatched > 0 ? totalRating / _totalMoviesWatched : 0;

      // Obtener géneros favoritos (top 3)
      final entries = _genrePreferences.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      _favoriteGenres = entries
          .map((e) => e.key)
          .take(3)
          .toList();
    } catch (e) {
      // Error al cargar patrones - continuar con valores por defecto
    }
  }

  /// Registra una película visualizada
  Future<void> recordMovieViewed({
    required String movieId,
    required String category,
    required double rating,
    required int watchDurationSeconds,
    required double completionPercentage,
  }) async {
    try {
      await _syncService.recordViewingPattern(
        movieId: movieId,
        category: category,
        rating: rating,
        watchDuration: watchDurationSeconds,
        completionPercentage: completionPercentage,
      );

      // Actualizar preferencias
      await _loadViewingPatterns();
      notifyListeners();
    } catch (e) {
      // Error registrando película - continuar sin error
    }
  }

  /// Genera recomendaciones basadas en Machine Learning
  Future<List<Movie>> generateRecommendations(
    List<Movie> availableMovies, {
    int maxRecommendations = 10,
  }) async {
    try {
      // Si no hay patrones suficientes, retornar películas populares
      if (_totalMoviesWatched < 3) {
        return _getPopularMovies(availableMovies, maxRecommendations);
      }

      // Calcular puntuación para cada película
      final scoredMovies = <MapEntry<Movie, double>>[];

      for (final movie in availableMovies) {
        double score = _calculateMovieScore(movie);
        scoredMovies.add(MapEntry(movie, score));
      }

      // Ordenar por puntuación
      scoredMovies.sort((a, b) => b.value.compareTo(a.value));

      _recommendations = scoredMovies
          .take(maxRecommendations)
          .map((entry) => entry.key)
          .toList();

      notifyListeners();
      return _recommendations;
    } catch (e) {
      // Error generando recomendaciones - retornar lista vacía
      return [];
    }
  }

  /// Calcula la puntuación de una película basada en preferencias
  double _calculateMovieScore(Movie movie) {
    double score = 0;

    // Factor 1: Coincidencia de género (40% del peso)
    final genreScore = _getGenreScore(movie.category);
    score += genreScore * 0.4;

    // Factor 2: Rating de la película (30% del peso)
    final ratingScore = _getRatingScore(movie.rating);
    score += ratingScore * 0.3;

    // Factor 3: Novedad (10% del peso) - Preferir películas más recientes
    final recencyScore = _getRecencyScore(movie.year);
    score += recencyScore * 0.1;

    // Factor 4: Similitud con películas vistas (20% del peso)
    final similarityScore = _getSimilarityScore(movie);
    score += similarityScore * 0.2;

    return score;
  }

  /// Calcula score basado en género
  double _getGenreScore(String genre) {
    if (_genrePreferences.isEmpty) return 0.5;

    final preference = _genrePreferences[genre] ?? 0;
    final maxPreference = _genrePreferences.values.reduce(max);

    if (maxPreference == 0) return 0.5;
    return preference / maxPreference;
  }

  /// Calcula score basado en rating
  double _getRatingScore(String ratingStr) {
    try {
      final rating = double.parse(ratingStr);
      // Normalizar rating a escala 0-1
      return (rating / 10).clamp(0, 1);
    } catch (e) {
      return 0.5;
    }
  }

  /// Calcula score basado en recencia (películas recientes son más atractivas)
  double _getRecencyScore(String yearStr) {
    try {
      final year = int.parse(yearStr);
      final currentYear = DateTime.now().year;
      final yearsDifference = currentYear - year;

      // Películas de los últimos 3 años: score alto
      if (yearsDifference <= 3) return 1.0;
      // Películas de 4-6 años: score medio
      if (yearsDifference <= 6) return 0.7;
      // Películas más antiguas: score más bajo pero no cero
      return max(0.3, 1.0 - (yearsDifference - 6) / 20);
    } catch (e) {
      return 0.5;
    }
  }

  /// Calcula similitud con películas vistas
  double _getSimilarityScore(Movie movie) {
    // Si no hay patrones suficientes, retornar score neutral
    if (_genrePreferences.isEmpty) return 0.5;

    // Verificar si el género está en preferencias
    if (_genrePreferences.containsKey(movie.category)) {
      return 0.8;
    }

    // Penalizar géneros no vistos
    return 0.3;
  }

  /// Obtiene películas populares como fallback
  List<Movie> _getPopularMovies(List<Movie> movies, int count) {
    final sorted = List<Movie>.from(movies);
    sorted.sort((a, b) {
      try {
        final ratingA = double.parse(a.rating);
        final ratingB = double.parse(b.rating);
        return ratingB.compareTo(ratingA);
      } catch (e) {
        return 0;
      }
    });
    return sorted.take(count).toList();
  }

  /// Obtiene recomendaciones basadas en una película específica
  Future<List<Movie>> getMovieSimilarRecommendations(
    Movie sourceMovie,
    List<Movie> availableMovies, {
    int maxRecommendations = 5,
  }) async {
    try {
      final similarMovies = <MapEntry<Movie, double>>[];

      for (final movie in availableMovies) {
        if (movie.id == sourceMovie.id) continue;

        double similarity = 0;

        // Mismo género
        if (movie.category == sourceMovie.category) {
          similarity += 0.5;
        }

        // Rating similar (diferencia < 1.5)
        try {
          final sourcRating = double.parse(sourceMovie.rating);
          final movieRating = double.parse(movie.rating);
          final ratingDiff = (sourcRating - movieRating).abs();
          if (ratingDiff < 1.5) {
            similarity += 0.3;
          }
        } catch (e) {
          // Ignorar errores de parsing
        }

        // Año similar (diferencia < 5 años)
        try {
          final sourceYear = int.parse(sourceMovie.year);
          final movieYear = int.parse(movie.year);
          final yearDiff = (sourceYear - movieYear).abs();
          if (yearDiff < 5) {
            similarity += 0.2;
          }
        } catch (e) {
          // Ignorar errores de parsing
        }

        if (similarity > 0) {
          similarMovies.add(MapEntry(movie, similarity));
        }
      }

      // Ordenar por similitud
      similarMovies.sort((a, b) => b.value.compareTo(a.value));

      return similarMovies
          .take(maxRecommendations)
          .map((entry) => entry.key)
          .toList();
    } catch (e) {
      // Error obteniendo similares - retornar lista vacía
      return [];
    }
  }

  /// Obtiene estadísticas del usuario
  Map<String, dynamic> getUserStatistics() {
    return {
      'total_movies_watched': _totalMoviesWatched,
      'average_rating': _averageRating.toStringAsFixed(2),
      'favorite_genres': _favoriteGenres,
      'genre_preferences': _genrePreferences,
      'total_recommendations': _recommendations.length,
    };
  }

  /// Obtiene recomendaciones actuales
  List<Movie> get recommendations => _recommendations;

  /// Obtiene géneros favoritos
  List<String> get favoriteGenres => _favoriteGenres;

  /// Obtiene promedio de rating del usuario
  double get averageUserRating => _averageRating;

  /// Limpia datos de recomendaciones
  void clearRecommendations() {
    _recommendations.clear();
    _genrePreferences.clear();
    _favoriteGenres.clear();
    _totalMoviesWatched = 0;
    _averageRating = 0;
    notifyListeners();
  }
}
