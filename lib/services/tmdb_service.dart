import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';
import 'connectivity_utils.dart';

class TMDBService {
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static const String _apiKey = '06fb91208cd7f218678fb7807fc8230b';
  static const String _accessToken =
      'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIwNmZiOTEyMDhjZDdmZjI4Njc4ZmI3ODA3ZmM4MjMwYiIsIm5iZiI6MTc2NjI0NjA5Mi43MDUsInN1YiI6IjY5NDZjNmNjYTg5NjBhMTkwOTA3MmM0MSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.TRVdzj6yplZwL_GnEWgKtUIEVm6M7CYQvhgEpk7h2as';

  static Future<List<Movie>> getPopularMovies({int page = 1}) async {
    return ConnectivityUtils.executeWithRetries(
      () async {
        final response = await http.get(
          Uri.parse('$_baseUrl/movie/popular?api_key=$_apiKey&page=$page'),
          headers: {
            'Authorization': 'Bearer $_accessToken',
          },
        ).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final List<dynamic> results = data['results'] ?? [];
          
          return results.map((movie) {
            return Movie(
              id: movie['id'].toString(),
              title: movie['title'] ?? 'Unknown',
              imageUrl: movie['poster_path'] != null
                  ? 'https://image.tmdb.org/t/p/w500${movie['poster_path']}'
                  : 'https://picsum.photos/300/400?random=default',
              category: _getCategoryFromGenres(movie['genre_ids'] ?? []),
              rating: (movie['vote_average'] ?? 0.0).toStringAsFixed(1),
              year: movie['release_date'] != null
                  ? movie['release_date'].toString().split('-')[0]
                  : 'N/A',
              description: movie['overview'] ?? 'Sin descripción disponible',
              cast: [],
            );
          }).toList();
        } else {
          throw Exception('Error al obtener películas: ${response.statusCode}');
        }
      },
      maxRetries: 3,
      retryDelay: const Duration(seconds: 2),
    );
  }

  static Future<List<Movie>> searchMovies(String query, {int page = 1}) async {
    // Validar query
    if (query.isEmpty || query.length > 100) {
      return [];
    }

    return ConnectivityUtils.executeWithRetries(
      () async {
        final response = await http.get(
          Uri.parse('$_baseUrl/search/movie?api_key=$_apiKey&query=$query&page=$page'),
          headers: {
            'Authorization': 'Bearer $_accessToken',
          },
        ).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final List<dynamic> results = data['results'] ?? [];
          
          return results.map((movie) {
            return Movie(
              id: movie['id'].toString(),
              title: movie['title'] ?? 'Unknown',
              imageUrl: movie['poster_path'] != null
                  ? 'https://image.tmdb.org/t/p/w500${movie['poster_path']}'
                  : 'https://picsum.photos/300/400?random=search',
              category: _getCategoryFromGenres(movie['genre_ids'] ?? []),
              rating: (movie['vote_average'] ?? 0.0).toStringAsFixed(1),
              year: movie['release_date'] != null
                  ? movie['release_date'].toString().split('-')[0]
                  : 'N/A',
              description: movie['overview'] ?? 'Sin descripción disponible',
              cast: [],
            );
          }).toList();
        } else {
          throw Exception('Error en la búsqueda: ${response.statusCode}');
        }
      },
      maxRetries: 3,
      retryDelay: const Duration(seconds: 2),
    );
  }

  static Future<Movie?> getMovieDetails(String movieId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/movie/$movieId?api_key=$_apiKey'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        return Movie(
          id: data['id'].toString(),
          title: data['title'] ?? 'Unknown',
          imageUrl: data['poster_path'] != null
              ? 'https://image.tmdb.org/t/p/w500${data['poster_path']}'
              : 'https://picsum.photos/300/400?random=detail',
          category: _getCategoryFromGenres(data['genres'] ?? []),
          rating: (data['vote_average'] ?? 0.0).toStringAsFixed(1),
          year: data['release_date'] != null
              ? data['release_date'].toString().split('-')[0]
              : 'N/A',
          description: data['overview'] ?? 'Sin descripción disponible',
          cast: (data['credits']?['cast'] as List?)
                  ?.take(5)
                  .map((actor) => actor['name'] as String)
                  .toList() ??
              [],
        );
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener detalles: $e');
    }
  }

  static String _getCategoryFromGenres(dynamic genres) {
    if (genres is List) {
      // Si son IDs de género
      if (genres.isNotEmpty && genres.first is int) {
        return _getGenreNameFromId(genres.first);
      }
      // Si son objetos de género
      if (genres.isNotEmpty && genres.first is Map) {
        return genres.first['name'] ?? 'General';
      }
    }
    return 'General';
  }

  static Future<List<Map<String, dynamic>>> getGenres() async {
    return ConnectivityUtils.executeWithRetries(
      () async {
        final response = await http.get(
          Uri.parse('$_baseUrl/genre/movie/list?api_key=$_apiKey'),
          headers: {
            'Authorization': 'Bearer $_accessToken',
          },
        ).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final List<dynamic> genres = data['genres'] ?? [];
          
          return genres.map((genre) {
            return {
            'id': genre['id'],
            'name': genre['name'],
          };
        }).toList();
        } else {
          throw Exception('Error al obtener géneros: ${response.statusCode}');
        }
      },
      maxRetries: 3,
      retryDelay: const Duration(seconds: 2),
    );
    }
  }

  static String _getGenreNameFromId(int genreId) {
    const genreMap = {
      28: 'Acción',
      12: 'Aventura',
      16: 'Animación',
      35: 'Comedia',
      80: 'Crimen',
      99: 'Documental',
      18: 'Drama',
      10751: 'Familia',
      14: 'Fantasía',
      36: 'Historia',
      27: 'Terror',
      10402: 'Música',
      9648: 'Misterio',
      10749: 'Romance',
      878: 'Sci-Fi',
      10770: 'Televisión',
      53: 'Thriller',
      10752: 'Guerra',
      37: 'Western',
    };
    return genreMap[genreId] ?? 'General';
  }
}
