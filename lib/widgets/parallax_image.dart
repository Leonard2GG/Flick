import 'package:flutter/material.dart';

/// Widget que crea efecto parallax en scroll
class ParallaxImage extends StatelessWidget {
  final String imageUrl;
  final ScrollController? scrollController;
  final double height;
  final BoxFit fit;

  const ParallaxImage({
    Key? key,
    required this.imageUrl,
    this.scrollController,
    this.height = 400,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: scrollController ?? ScrollController(),
      builder: (context, child) {
        double offset = 0;
        if (scrollController != null && scrollController!.hasClients) {
          offset = scrollController!.offset * 0.5; // Parallax factor
        }

        return Transform.translate(
          offset: Offset(0, offset),
          child: SizedBox(
            height: height,
            width: double.infinity,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(0),
              child: Image.network(
                imageUrl,
                fit: fit,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[900],
                    child: const Center(
                      child: Icon(Icons.movie, size: 80, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Widget para crear efecto blur/blur en scroll
class BlurredBackground extends StatelessWidget {
  final String imageUrl;
  final ScrollController? scrollController;
  final double blurStrength;
  final double height;

  const BlurredBackground({
    Key? key,
    required this.imageUrl,
    this.scrollController,
    this.blurStrength = 20,
    this.height = 300,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Imagen base
          Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[900],
              );
            },
          ),

          // Gradientes decorativos
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
