import 'package:flutter/material.dart';

/// Widget para mostrar todas las categorías de TMDB en forma de grid
class CategoriesGridWidget extends StatefulWidget {
  final List<Map<String, dynamic>> categories;
  final Function(int, String)? onCategoryTap;

  const CategoriesGridWidget({
    super.key,
    required this.categories,
    this.onCategoryTap,
  });

  @override
  State<CategoriesGridWidget> createState() => _CategoriesGridWidgetState();
}

class _CategoriesGridWidgetState extends State<CategoriesGridWidget> {
  // Mapa de IDs de TMDB a colores y gradientes
  final Map<int, Map<String, dynamic>> _categoryStyles = {
    28: {'color': Colors.red.shade700, 'gradient': [Colors.red.shade700, Colors.red.shade400]},
    12: {'color': Colors.amber.shade700, 'gradient': [Colors.amber.shade700, Colors.amber.shade400]},
    16: {'color': Colors.pink.shade700, 'gradient': [Colors.pink.shade700, Colors.pink.shade400]},
    35: {'color': Colors.blue.shade700, 'gradient': [Colors.blue.shade700, Colors.blue.shade400]},
    80: {'color': Colors.blueGrey.shade700, 'gradient': [Colors.blueGrey.shade700, Colors.blueGrey.shade400]},
    99: {'color': Colors.green.shade700, 'gradient': [Colors.green.shade700, Colors.green.shade400]},
    18: {'color': Colors.deepOrange.shade700, 'gradient': [Colors.deepOrange.shade700, Colors.deepOrange.shade400]},
    10751: {'color': Colors.lightBlue.shade700, 'gradient': [Colors.lightBlue.shade700, Colors.lightBlue.shade400]},
    14: {'color': Colors.deepPurple.shade900, 'gradient': [Colors.deepPurple.shade900, Colors.deepPurple.shade600]},
    36: {'color': Colors.brown.shade700, 'gradient': [Colors.brown.shade700, Colors.brown.shade400]},
    27: {'color': Colors.purple.shade900, 'gradient': [Colors.purple.shade900, Colors.purple.shade600]},
    10402: {'color': Colors.orange.shade700, 'gradient': [Colors.orange.shade700, Colors.orange.shade400]},
    9648: {'color': Colors.purpleAccent.shade700, 'gradient': [Colors.purpleAccent.shade700, Colors.purpleAccent.shade400]},
    10749: {'color': Colors.pinkAccent.shade700, 'gradient': [Colors.pinkAccent.shade700, Colors.pinkAccent.shade400]},
    878: {'color': Colors.cyan.shade700, 'gradient': [Colors.cyan.shade700, Colors.cyan.shade400]},
    10770: {'color': Colors.teal.shade700, 'gradient': [Colors.teal.shade700, Colors.teal.shade400]},
    53: {'color': Colors.indigo.shade700, 'gradient': [Colors.indigo.shade700, Colors.indigo.shade400]},
    10752: {'color': Colors.grey.shade700, 'gradient': [Colors.grey.shade700, Colors.grey.shade400]},
    37: {'color': Colors.orange.shade900, 'gradient': [Colors.orange.shade900, Colors.orange.shade600]},
  };

  List<Color>? _getGradientForCategory(int id) {
    final style = _categoryStyles[id];
    return style != null ? List<Color>.from(style['gradient']) : [Colors.grey.shade700, Colors.grey.shade400];
  }

  Color _getColorForCategory(int id) {
    final style = _categoryStyles[id];
    return style != null ? style['color'] : Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: const Text(
              'Todas las Categorías',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: widget.categories.length,
              itemBuilder: (context, index) {
                final category = widget.categories[index];
                final categoryId = category['id'] as int;
                final categoryName = category['name'] as String;
                final gradientColors = _getGradientForCategory(categoryId);
                final color = _getColorForCategory(categoryId);

                return _CategoryCardTile(
                  name: categoryName,
                  color: color,
                  gradientColors: gradientColors,
                  onTap: () {
                    widget.onCategoryTap?.call(categoryId, categoryName);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Tile individual de categoría con estilo card
class _CategoryCardTile extends StatelessWidget {
  final String name;
  final Color color;
  final List<Color>? gradientColors;
  final VoidCallback? onTap;

  const _CategoryCardTile({
    required this.name,
    required this.color,
    this.gradientColors,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: gradientColors != null && gradientColors!.length >= 2
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradientColors!,
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color.withValues(alpha: 0.8), color],
                ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
