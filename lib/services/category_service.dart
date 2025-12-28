import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/movie.dart';

/// Servicio para obtener categorías y películas nuevas de TMDB
class CategoryService {
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static const String _apiKey = '06fb91208cd7f218678fb7807fc8230b';

  /// Obtiene todas las categorías (géneros) de TMDB
  static Future<List<Map<String, dynamic>>> getAllCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/genre/movie/list?api_key=$_apiKey&language=es-ES'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final genres = (data['genres'] as List)
            .map((g) => {
              'id': g['id'],
              'name': g['name'],
            })
            .toList();
        return genres;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Obtiene películas nuevas de estreno (upcoming)
  static Future<List<Movie>> getUpcomingMovies() async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/movie/upcoming?api_key=$_apiKey&language=es-ES&region=ES&page=1',
        ),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final movies = (data['results'] as List)
            .map((movie) => Movie(
              id: movie['id'].toString(),
              title: movie['title'] ?? 'Sin título',
              category: _getCategoryFromGenres(movie['genre_ids']),
              rating: (movie['vote_average'] ?? 0).toString(),
              year: movie['release_date'] != null
                  ? movie['release_date'].substring(0, 4)
                  : 'Próximamente',
              description: movie['overview'] ?? '',
              imageUrl:
                  'https://image.tmdb.org/t/p/w500${movie['poster_path'] ?? ''}',
              cast: [],
            ))
            .take(10)
            .toList();
        return movies;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Obtiene películas por categoría específica
  static Future<List<Movie>> getMoviesByCategory(int categoryId) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/discover/movie?api_key=$_apiKey&language=es-ES&with_genres=$categoryId&page=1',
        ),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final movies = (data['results'] as List)
            .map((movie) => Movie(
              id: movie['id'].toString(),
              title: movie['title'] ?? 'Sin título',
              category: _getCategoryFromGenres(movie['genre_ids']),
              rating: (movie['vote_average'] ?? 0).toString(),
              year: movie['release_date'] != null
                  ? movie['release_date'].substring(0, 4)
                  : 'Desconocido',
              description: movie['overview'] ?? '',
              imageUrl:
                  'https://image.tmdb.org/t/p/w500${movie['poster_path'] ?? ''}',
              cast: [],
            ))
            .toList();
        return movies;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Helper para obtener categoría a partir de IDs de géneros
  static String _getCategoryFromGenres(List<dynamic> genreIds) {
    if (genreIds.isEmpty) return 'Películas';
    // Por ahora retorna un nombre genérico, idealmente usarías el mapeo de IDs
    return 'Películas';
  }

  /// Obtiene películas populares
  static Future<List<Movie>> getPopularMovies() async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/movie/popular?api_key=$_apiKey&language=es-ES&page=1',
        ),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final movies = (data['results'] as List)
            .map((movie) => Movie(
              id: movie['id'].toString(),
              title: movie['title'] ?? 'Sin título',
              category: _getCategoryFromGenres(movie['genre_ids']),
              rating: (movie['vote_average'] ?? 0).toString(),
              year: movie['release_date'] != null
                  ? movie['release_date'].substring(0, 4)
                  : 'Desconocido',
              description: movie['overview'] ?? '',
              imageUrl:
                  'https://image.tmdb.org/t/p/w500${movie['poster_path'] ?? ''}',
              cast: [],
            ))
            .toList();
        return movies;
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
