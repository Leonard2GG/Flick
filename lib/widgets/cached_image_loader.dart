import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

/// Widget para cargar imágenes con cache y skeleton loader
class CachedImageLoader extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final Widget? errorWidget;

  const CachedImageLoader({
    Key? key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.width,
    this.height,
    this.placeholder,
    this.errorWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: fit,
        width: width,
        height: height,
        placeholder: (context, url) {
          return placeholder ?? _buildSkeletonLoader();
        },
        errorWidget: (context, url, error) {
          return errorWidget ??
              Container(
                color: Colors.grey[900],
                child: const Center(
                  child: Icon(
                    Icons.movie,
                    size: 50,
                    color: Colors.grey,
                  ),
                ),
              );
        },
        fadeInDuration: const Duration(milliseconds: 300),
        fadeOutDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  /// Widget de skeleton loader con shimmer effect
  Widget _buildSkeletonLoader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[850]!,
      highlightColor: Colors.grey[700]!,
      child: Container(
        width: width,
        height: height,
        color: Colors.grey[800],
      ),
    );
  }
}

/// Skeleton loader para tarjetas de películas
class MovieCardSkeleton extends StatelessWidget {
  final double? width;
  final double? height;

  const MovieCardSkeleton({
    Key? key,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[850]!,
      highlightColor: Colors.grey[700]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

/// Skeleton loader para lista de películas
class MovieListSkeleton extends StatelessWidget {
  final int itemCount;

  const MovieListSkeleton({
    Key? key,
    this.itemCount = 5,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          height: 120,
          child: Row(
            children: [
              MovieCardSkeleton(width: 90, height: 120),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MovieCardSkeleton(width: double.infinity, height: 16),
                    const SizedBox(height: 12),
                    MovieCardSkeleton(width: 150, height: 12),
                    const SizedBox(height: 12),
                    MovieCardSkeleton(width: 200, height: 12),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
