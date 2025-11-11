import 'package:animations/animations.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class MarkerImageCarousel extends StatelessWidget {
  const MarkerImageCarousel({
    super.key,
    required this.imageUrls,
    required this.currentIndex,
    required this.onPageChanged,
  });

  final List<String> imageUrls;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) {
      return const _EmptyGallery();
    }

    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: imageUrls.length,
          options: CarouselOptions(
            height: 300,
            enableInfiniteScroll: false,
            enlargeCenterPage: true,
            viewportFraction: 1,
            onPageChanged: (index, reason) {
              _prefetchNeighbor(index);
              onPageChanged(index);
            },
          ),
          itemBuilder: (context, index, realIndex) {
            final url = imageUrls[index];
            return ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: GestureDetector(
                onTap: () {
                  showGeneralDialog(
                    context: context,
                    barrierDismissible: true,
                    barrierLabel: "Dismiss",
                    barrierColor: Colors.black.withValues(alpha: 0.8),
                    transitionDuration: const Duration(milliseconds: 300),
                    pageBuilder: (_, __, ___) => Center(
                      child: InteractiveViewer(
                        child: CachedNetworkImage(
                          imageUrl: url,
                          fit: BoxFit.contain,
                          placeholder: (context, _) => const _DialogLoader(),
                          errorWidget: (context, _, __) => const _DialogError(),
                          memCacheWidth: 1200,
                          memCacheHeight: 1200,
                          maxWidthDiskCache: 1600,
                          maxHeightDiskCache: 1600,
                        ),
                      ),
                    ),
                    transitionBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return FadeScaleTransition(
                          animation: animation, child: child);
                    },
                  );
                },
                child: CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.cover,
                  fadeInDuration: const Duration(milliseconds: 200),
                  placeholderFadeInDuration: const Duration(milliseconds: 150),
                  placeholder: (context, _) => const _TileLoader(),
                  errorWidget: (context, _, __) => const _TileError(),
                  memCacheWidth: 900,
                  memCacheHeight: 900,
                  maxWidthDiskCache: 1200,
                  maxHeightDiskCache: 1200,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: imageUrls.asMap().entries.map((entry) {
            final isActive = currentIndex == entry.key;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isActive ? 10.0 : 8.0,
              height: isActive ? 10.0 : 8.0,
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? Colors.black : Colors.grey,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _prefetchNeighbor(int index) {
    if (index + 1 < imageUrls.length) {
      CachedNetworkImageProvider(imageUrls[index + 1])
          .resolve(const ImageConfiguration());
    }
    if (index - 1 >= 0) {
      CachedNetworkImageProvider(imageUrls[index - 1])
          .resolve(const ImageConfiguration());
    }
  }
}

class _EmptyGallery extends StatelessWidget {
  const _EmptyGallery();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'Brak zdjęć',
        style: TextStyle(
            fontSize: 16, color: Colors.black54, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _TileLoader extends StatelessWidget {
  const _TileLoader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[300],
      alignment: Alignment.center,
      child: const SizedBox(
        width: 28,
        height: 28,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}

class _TileError extends StatelessWidget {
  const _TileError();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[300],
      alignment: Alignment.center,
      child: const Icon(Icons.broken_image, size: 28, color: Colors.grey),
    );
  }
}

class _DialogLoader extends StatelessWidget {
  const _DialogLoader();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 36,
      height: 36,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
  }
}

class _DialogError extends StatelessWidget {
  const _DialogError();

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.broken_image, size: 40, color: Colors.white70);
  }
}
