import 'package:flutter/material.dart';
import '../screens/discovery_screen.dart';
import '../services/tmdb_service.dart';

class MovieSearchDelegate extends SearchDelegate {
  @override
  String get searchFieldLabel => 'Buscar película...';

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF121212),
        elevation: 1,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.grey),
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      Padding(
        padding: const EdgeInsets.only(right: 16),
        child: IconButton(
          icon: const Icon(Icons.clear, color: Colors.greenAccent),
          onPressed: () => query = '',
        ),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Center(
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.greenAccent),
          onPressed: () => close(context, null),
        ),
      ),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return _buildEmptyState();
    }
    return _buildSearchResults(context);
  }

  Widget _buildEmptyState() {
    return Container(
      color: const Color(0xFF121212),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.movie, size: 80, color: Colors.grey[800]),
            const SizedBox(height: 16),
            Text(
              'Escribe para buscar películas',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context) {
    if (query.isEmpty) {
      return _buildEmptyState();
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 80, color: Colors.red[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Error al buscar',
                    style: TextStyle(color: Colors.red[400], fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        }

        final results = snapshot.data ?? [];

        if (results.isEmpty) {
          return Container(
            color: const Color(0xFF121212),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 80, color: Colors.grey[800]),
                  const SizedBox(height: 16),
                  Text(
                    'No se encontraron películas',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
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
              title: Text(
                results[i].title,
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                results[i].year,
                style: TextStyle(color: Colors.grey[500]),
              ),
              onTap: () {
                close(context, null);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DiscoveryScreen(
                      categoryName: results[i].category,
                      fromSearch: true,
                    ),
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