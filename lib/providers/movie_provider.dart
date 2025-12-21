import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/movie.dart';

class MovieProvider with ChangeNotifier {
  final List<Movie> _watchlist = [];
  late SharedPreferences _prefs;
  bool _isInitialized = false;

  static const String _watchlistKey = 'watchlist_movies';

  // Getter para el watchlist
  List<Movie> get watchlist => _watchlist;
  bool get isInitialized => _isInitialized;

  // Inicializar SharedPreferences y cargar watchlist
  Future<void> init() async {
    if (_isInitialized) return;
    
    _prefs = await SharedPreferences.getInstance();
    await _loadWatchlist();
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
      notifyListeners();
    } catch (e) {
      print('Error al cargar watchlist: $e');
    }
  }

  // Guardar watchlist en SharedPreferences
  Future<void> _saveWatchlist() async {
    try {
      final List<String> moviesJson =
          _watchlist.map((movie) => movie.toJsonString()).toList();
      await _prefs.setStringList(_watchlistKey, moviesJson);
      notifyListeners();
    } catch (e) {
      print('Error al guardar watchlist: $e');
    }
  }

  // Agregar película a watchlist
  Future<void> addToWatchlist(Movie movie) async {
    if (!_watchlist.any((m) => m.id == movie.id)) {
      _watchlist.add(movie);
      await _saveWatchlist();
    }
  }

  // Eliminar película del watchlist
  Future<void> removeFromWatchlist(Movie movie) async {
    _watchlist.removeWhere((m) => m.id == movie.id);
    await _saveWatchlist();
  }

  // Limpiar todo el watchlist
  Future<void> clearWatchlist() async {
    _watchlist.clear();
    await _prefs.remove(_watchlistKey);
    notifyListeners();
  }
}