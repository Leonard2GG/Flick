import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import '../widgets/cached_image_loader.dart';
import '../services/tmdb_service.dart';
import '../widgets/share_movie_bottom_sheet.dart';
import '../models/movie.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  late TextEditingController _searchController;
  String _searchQuery = '';
  String? _selectedMovieId;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedMovieId == null
          ? AppBar(
              title: const Text(
                'MI LISTA',
                style: TextStyle(letterSpacing: 4, fontWeight: FontWeight.bold, color: Colors.greenAccent),
              ),
              backgroundColor: const Color(0xFF121212),
              elevation: 0,
              centerTitle: true,
            )
          : null,
      body: Consumer<MovieProvider>(
        builder: (context, movieProvider, child) {
          final all = movieProvider.watchlist;
          final movies = all.where((m) => m.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

          // Si hay película seleccionada, mostrar vista de detalles
          if (_selectedMovieId != null) {
            final selectedIndex = movies.indexWhere((m) => m.id == _selectedMovieId);
            if (selectedIndex == -1) {
              _selectedMovieId = null;
              return _buildListView(movies, movieProvider);
            }
            return _buildDetailView(movies[selectedIndex], movieProvider);
          }

          return _buildListView(movies, movieProvider);
        },
      ),
    );
  }

  Widget _buildListView(List movies, MovieProvider movieProvider) {
    return Column(
      children: [
        _buildSearchPanel(),
        Expanded(
          child: movies.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.movie_filter, size: 80, color: Colors.grey[800]),
                      const SizedBox(height: 16),
                      const Text(
                        'Tu lista está vacía',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '¡Empieza a deslizar para añadir!',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: movies.length,
                  itemBuilder: (context, index) {
                    final movie = movies[index];
                    final isFavorite = movieProvider.isFavorite(movie.id);

                    return GestureDetector(
                      onTap: () => setState(() => _selectedMovieId = movie.id),
                      child: ListTile(
                        leading: CachedImageLoader(
                          imageUrl: movie.imageUrl,
                          width: 50,
                          height: 70,
                          fit: BoxFit.cover,
                        ),
                        title: Text(
                          movie.title,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Row(
                          children: [
                            Text(
                              movie.year,
                              style: TextStyle(color: Colors.grey[500], fontSize: 12),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.star, size: 12, color: Colors.yellow[600]),
                            const SizedBox(width: 4),
                            Text(
                              movie.rating,
                              style: const TextStyle(
                                color: Colors.greenAccent,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (isFavorite) ...[
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.favorite,
                                color: Colors.redAccent,
                                size: 12,
                              ),
                            ],
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () {
                                movieProvider.removeFromWatchlist(movie);
                                setState(() {});
                              },
                              child: const Icon(
                                Icons.delete_outline,
                                color: Colors.redAccent,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.chevron_right, color: Colors.greenAccent),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildDetailView(Movie movie, MovieProvider movieProvider) {

    return Stack(
      fit: StackFit.expand,
      children: [
        // Imagen de fondo
        Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.grey[900],
          child: CachedImageLoader(
            imageUrl: movie.imageUrl,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        // Gradient overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.3),
                Colors.black.withValues(alpha: 0.9),
              ],
            ),
          ),
        ),
        // Información en la parte inferior
        Positioned(
          bottom: 80,
          left: 20,
          right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                movie.title,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      movie.category,
                      style: TextStyle(
                        color: Colors.blue[800],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        movie.rating,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    movie.year,
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  // Botón de favorito
                  GestureDetector(
                    onTap: () {
                      movieProvider.toggleFavorite(movie.id);
                      setState(() {});
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        movieProvider.isFavorite(movie.id)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: Colors.redAccent,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Botón de compartir
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) =>
                            ShareMovieBottomSheet(movie: movie),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.share,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            ],
          ),
        ),
        // Panel deslizable hacia arriba
        _buildDetailsSheet(movie),
        // Botón de atrás flotante encima de la imagen
        Positioned(
          top: 16,
          left: 16,
          child: GestureDetector(
            onTap: () => setState(() => _selectedMovieId = null),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.chevron_left_sharp,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsSheet(Movie movie) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.05,
      minChildSize: 0.05,
      maxChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF121212),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    movie.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          movie.category,
                          style: TextStyle(
                            color: Colors.blue[800],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            movie.rating,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        movie.year,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Descripción',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    movie.description,
                    style: TextStyle(
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Reparto',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Cargar reparto desde TMDB
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: TMDBService.getMovieCast(movie.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.greenAccent,
                            ),
                          ),
                        );
                      }

                      if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Text(
                            'Sin información de reparto',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        );
                      }

                      final castList = snapshot.data!;
                      return GridView.count(
                        crossAxisCount: 3,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        children: castList.map((actor) {
                          final profilePath = actor['profilePath'] ?? '';
                          final hasImage = profilePath.isNotEmpty;

                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              hasImage
                                  ? ClipOval(
                                      child: CachedImageLoader(
                                        imageUrl: profilePath,
                                        width: 70,
                                        height: 70,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Container(
                                      width: 70,
                                      height: 70,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.greenAccent.withValues(
                                          alpha: 0.3,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.person,
                                        size: 35,
                                        color: Colors.greenAccent,
                                      ),
                                    ),
                              const SizedBox(height: 8),
                              Text(
                                actor['name']!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchPanel() {
    return Container(
      color: const Color(0xFF121212),
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.greenAccent.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.greenAccent),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Buscar películas',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                style: const TextStyle(color: Colors.white),
                cursorColor: Colors.greenAccent,
              ),
            ),
            if (_searchQuery.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
                child: const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.clear, color: Colors.grey, size: 20),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
