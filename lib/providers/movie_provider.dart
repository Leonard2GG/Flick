import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/movie.dart';

class MovieProvider with ChangeNotifier {
  final List<Movie> _watchlist = [];
  final List<Movie> _history = [];
  final Map<String, double> _userRatings = {}; // id -> rating
  final Set<String> _favorites = {};
  late SharedPreferences _prefs;
  bool _isInitialized = false;

  static const String _watchlistKey = 'watchlist_movies';
  static const String _historyKey = 'history_movies';
  static const String _ratingsKey = 'user_ratings';
  static const String _favoritesKey = 'favorite_movies';

  // Getters
  List<Movie> get watchlist => _watchlist;
  List<Movie> get history => _history;
  bool get isInitialized => _isInitialized;
  
  bool isInWatchlist(String movieId) => _watchlist.any((m) => m.id == movieId);
  bool isFavorite(String movieId) => _favorites.contains(movieId);
  double getUserRating(String movieId) => _userRatings[movieId] ?? 0.0;

  // Inicializar SharedPreferences y cargar datos
  Future<void> init() async {
    if (_isInitialized) return;
    
    _prefs = await SharedPreferences.getInstance();
    await Future.wait([
      _loadWatchlist(),
      _loadHistory(),
      _loadRatings(),
      _loadFavorites(),
    ]);
    _isInitialized = true;
    notifyListeners();
  }

  // Cargar watchlist desde SharedPreferences
  Future<void> _loadWatchlist() async {
    try {
      final List<String>? savedMovies = _prefs.getStringList(_watchlistKey);
      if (savedMovies != null && savedMovies.isNotEmpty) {
        _watchlist.clear();
        for (final movieJson in savedMovies) {
          final movie = Movie.fromJsonString(movieJson);
          _watchlist.add(movie);
        }
      }
    } catch (e) {
      print('Error al cargar watchlist: $e');
    }
  }

  // Cargar historial desde SharedPreferences
  Future<void> _loadHistory() async {
    try {
      final List<String>? savedHistory = _prefs.getStringList(_historyKey);
      if (savedHistory != null && savedHistory.isNotEmpty) {
        _history.clear();
        for (final movieJson in savedHistory) {
          final movie = Movie.fromJsonString(movieJson);
          _history.add(movie);
        }
      }
    } catch (e) {
      print('Error al cargar historial: $e');
    }
  }

  // Cargar ratings desde SharedPreferences
  Future<void> _loadRatings() async {
    try {
      final ratingsJson = _prefs.getString(_ratingsKey);
      if (ratingsJson != null) {
        // Simple parsing
        for (final entry in (ratingsJson.split(';'))) {
          final parts = entry.split(':');
          if (parts.length == 2) {
            _userRatings[parts[0]] = double.tryParse(parts[1]) ?? 0.0;
          }
        }
      }
    } catch (e) {
      print('Error al cargar ratings: $e');
    }
  }

  // Cargar favoritos desde SharedPreferences
  Future<void> _loadFavorites() async {
    try {
      final favList = _prefs.getStringList(_favoritesKey);
      if (favList != null) {
        _favorites.clear();
        _favorites.addAll(favList);
      }
    } catch (e) {
      print('Error al cargar favoritos: $e');
    }
  }

  // Guardar watchlist
  Future<void> _saveWatchlist() async {
    try {
      final List<String> moviesJson =
          _watchlist.map((movie) => movie.toJsonString()).toList();
      await _prefs.setStringList(_watchlistKey, moviesJson);
    } catch (e) {
      print('Error al guardar watchlist: $e');
    }
  }

  // Guardar historial
  Future<void> _saveHistory() async {
    try {
      final List<String> historyJson =
          _history.map((movie) => movie.toJsonString()).toList();
      await _prefs.setStringList(_historyKey, historyJson);
    } catch (e) {
      print('Error al guardar historial: $e');
    }
  }

  // Guardar ratings
  Future<void> _saveRatings() async {
    try {
      final ratingsString = _userRatings.entries
          .map((e) => '${e.key}:${e.value}')
          .join(';');
      await _prefs.setString(_ratingsKey, ratingsString);
    } catch (e) {
      print('Error al guardar ratings: $e');
    }
  }

  // Guardar favoritos
  Future<void> _saveFavorites() async {
    try {
      await _prefs.setStringList(_favoritesKey, _favorites.toList());
    } catch (e) {
      print('Error al guardar favoritos: $e');
    }
  }

  // Agregar película a watchlist
  Future<void> addToWatchlist(Movie movie) async {
    if (!_watchlist.any((m) => m.id == movie.id)) {
      final movieToAdd = movie.copyWith(
        addedToWatchlistAt: DateTime.now(),
      );
      _watchlist.add(movieToAdd);
      await _saveWatchlist();
      notifyListeners();
    }
  }

  // Eliminar película del watchlist
  Future<void> removeFromWatchlist(Movie movie) async {
    _watchlist.removeWhere((m) => m.id == movie.id);
    await _saveWatchlist();
    notifyListeners();
  }

  // Agregar a historial (películas vistas)
  Future<void> addToHistory(Movie movie) async {
    // Remover si ya existe para evitar duplicados
    _history.removeWhere((m) => m.id == movie.id);
    // Agregar al inicio con fecha actual
    final movieToAdd = movie.copyWith(viewedAt: DateTime.now());
    _history.insert(0, movieToAdd);
    // Mantener solo las últimas 50 películas vistas
    if (_history.length > 50) {
      _history.removeRange(50, _history.length);
    }
    await _saveHistory();
    notifyListeners();
  }

  // Agregar/remover de favoritos
  Future<void> toggleFavorite(String movieId) async {
    if (_favorites.contains(movieId)) {
      _favorites.remove(movieId);
    } else {
      _favorites.add(movieId);
    }
    await _saveFavorites();
    notifyListeners();
  }

  // Establecer rating personal
  Future<void> setUserRating(String movieId, double rating) async {
    if (rating > 0) {
      _userRatings[movieId] = rating.clamp(0.0, 10.0);
    } else {
      _userRatings.remove(movieId);
    }
    await _saveRatings();
    notifyListeners();
  }

  // Limpiar todo el watchlist
  Future<void> clearWatchlist() async {
    _watchlist.clear();
    await _prefs.remove(_watchlistKey);
    notifyListeners();
  }

  // Limpiar historial
  Future<void> clearHistory() async {
    _history.clear();
    await _prefs.remove(_historyKey);
    notifyListeners();
  }

  // Obtener películas filtradas por año y rating
  List<Movie> getFilteredWatchlist({
    int? minYear,
    int? maxYear,
    double? minRating,
  }) {
    return _watchlist.where((movie) {
      final year = int.tryParse(movie.year) ?? 0;
      if (minYear != null && year < minYear) return false;
      if (maxYear != null && year > maxYear) return false;
      if (minRating != null) {
        final rating = double.tryParse(movie.rating) ?? 0.0;
        if (rating < minRating) return false;
      }
      return true;
    }).toList();
  }
}