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
}