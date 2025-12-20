import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import '../screens/discovery_screen.dart';

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
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    final movies = context.read<MovieProvider>().allMovies;
    final results = movies.where((m) => m.title.toLowerCase().contains(query.toLowerCase())).toList();

    return Container(
      color: const Color(0xFF121212),
      child: ListView.builder(
        itemCount: results.length,
        itemBuilder: (context, i) => ListTile(
          leading: Image.network(results[i].imageUrl, width: 50, fit: BoxFit.cover),
          title: Text(results[i].title),
          subtitle: Text(results[i].year),
          onTap: () {
            // Al tocar una búsqueda, vamos a la vista de detalle o swipe
            close(context, null);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DiscoveryScreen(categoryName: results[i].title)),
            );
          },
        ),
      ),
    );
  }
}