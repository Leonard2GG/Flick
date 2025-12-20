import 'package:flutter/material.dart';
import '../models/movie.dart';

class MovieProvider with ChangeNotifier {
  final List<Movie> _watchlist = [];
  
  // Lista maestra de películas (simulando una base de datos)
  final List<Movie> _allMovies = [
    Movie(
      id: '1',
      title: 'Dune: Part Two',
      imageUrl: 'https://image.tmdb.org/t/p/original/8uS9LnI3S78vnoo6ZWY9Y09p7vX.jpg',
      description: 'Paul Atreides se une a Chani y los Fremen mientras busca venganza.',
      rating: '8.8',
      year: '2024',
      cast: ['Timothée Chalamet', 'Zendaya'],
      category: 'Sci-Fi',
    ),
    Movie(
      id: '2',
      title: 'Oppenheimer',
      imageUrl: 'https://image.tmdb.org/t/p/original/8GxvA9zDZUGPBq9Y30YgG3A3Y5.jpg',
      description: 'La historia del científico J. Robert Oppenheimer.',
      rating: '8.5',
      year: '2023',
      cast: ['Cillian Murphy', 'Emily Blunt'],
      category: 'Drama',
    ),
  ];

  List<Movie> get watchlist => _watchlist;
  List<Movie> get allMovies => _allMovies;

  void addToWatchlist(Movie movie) {
    if (!_watchlist.any((m) => m.id == movie.id)) {
      _watchlist.add(movie);
      notifyListeners();
    }
  }

  void removeFromWatchlist(Movie movie) {
    _watchlist.removeWhere((m) => m.id == movie.id);
    notifyListeners();
  }
}