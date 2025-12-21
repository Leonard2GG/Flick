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

  Movie({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.description,
    required this.rating,
    required this.year,
    required this.cast,
    required this.category,
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
    );
  }

  // Convertir Movie a string JSON
  String toJsonString() => jsonEncode(toJson());

  // Crear Movie desde string JSON
  factory Movie.fromJsonString(String jsonString) {
    return Movie.fromJson(jsonDecode(jsonString));
  }
}