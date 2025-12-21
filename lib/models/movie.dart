import 'dart:convert';

class Movie {
  final String id;
  final String title;
  final String imageUrl;
  final String description;
  final String rating;
  final String year;
  final List<String> cast;
  final String category;
  final double userRating; // Rating personal del usuario (0-10)
  final bool isFavorite; // Si está marcado como favorito
  final DateTime? viewedAt; // Fecha de última visualización
  final DateTime? addedToWatchlistAt; // Fecha de cuando se agregó al watchlist

  Movie({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.description,
    required this.rating,
    required this.year,
    required this.cast,
    required this.category,
    this.userRating = 0.0,
    this.isFavorite = false,
    this.viewedAt,
    this.addedToWatchlistAt,
  });

  // Convertir Movie a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'description': description,
      'rating': rating,
      'year': year,
      'cast': cast,
      'category': category,
      'userRating': userRating,
      'isFavorite': isFavorite,
      'viewedAt': viewedAt?.toIso8601String(),
      'addedToWatchlistAt': addedToWatchlistAt?.toIso8601String(),
    };
  }

  // Crear Movie desde JSON
  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      description: json['description'] ?? '',
      rating: json['rating'] ?? '0.0',
      year: json['year'] ?? '',
      cast: List<String>.from(json['cast'] ?? []),
      category: json['category'] ?? '',
      userRating: (json['userRating'] ?? 0.0).toDouble(),
      isFavorite: json['isFavorite'] ?? false,
      viewedAt: json['viewedAt'] != null ? DateTime.parse(json['viewedAt']) : null,
      addedToWatchlistAt: json['addedToWatchlistAt'] != null ? DateTime.parse(json['addedToWatchlistAt']) : null,
    );
  }

  // Convertir Movie a string JSON
  String toJsonString() => jsonEncode(toJson());

  // Crear Movie desde string JSON
  factory Movie.fromJsonString(String jsonString) {
    return Movie.fromJson(jsonDecode(jsonString));
  }

  // Crear copia con cambios
  Movie copyWith({
    double? userRating,
    bool? isFavorite,
    DateTime? viewedAt,
  }) {
    return Movie(
      id: id,
      title: title,
      imageUrl: imageUrl,
      description: description,
      rating: rating,
      year: year,
      cast: cast,
      category: category,
      userRating: userRating ?? this.userRating,
      isFavorite: isFavorite ?? this.isFavorite,
      viewedAt: viewedAt ?? this.viewedAt,
      addedToWatchlistAt: addedToWatchlistAt,
    );
  }
}