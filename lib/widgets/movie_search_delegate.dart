import 'package:flutter/material.dart';
import '../screens/discovery_screen.dart';
import '../services/tmdb_service.dart';

class MovieSearchDelegate extends SearchDelegate {
  @override
  String get searchFieldLabel => 'Buscar película...';

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.grey),
        border: InputBorder.none,
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return Container(
        color: const Color(0xFF121212),
        child: Center(
          child: Text(
            'Escribe para buscar películas',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    if (query.isEmpty) {
      return Container(
        color: const Color(0xFF121212),
        child: Center(
          child: Text(
            'Escribe para buscar películas',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }

    return FutureBuilder(
      future: TMDBService.searchMovies(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            color: const Color(0xFF121212),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.greenAccent),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Container(
            color: const Color(0xFF121212),
            child: Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        final results = snapshot.data ?? [];

        if (results.isEmpty) {
          return Container(
            color: const Color(0xFF121212),
            child: Center(
              child: Text(
                'No se encontraron películas',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          );
        }

        return Container(
          color: const Color(0xFF121212),
          child: ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, i) => ListTile(
              leading: Image.network(
                results[i].imageUrl,
                width: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 50,
                  color: Colors.grey[900],
                  child: const Icon(Icons.movie, size: 25, color: Colors.grey),
                ),
              ),
              title: Text(results[i].title),
              subtitle: Text(results[i].year),
              onTap: () {
                // Al tocar una búsqueda, vamos a la vista de detalle o swipe
                close(context, null);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        DiscoveryScreen(categoryName: results[i].title, fromSearch: true),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}