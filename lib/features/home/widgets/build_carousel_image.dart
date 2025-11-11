import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class BuildCarouselImage extends StatelessWidget {
  const BuildCarouselImage({
    super.key,
    required this.urlImage,
    required this.title,
  });

  final String urlImage;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: double.infinity,
          height: 100,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildImage(),
              _buildTitleOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (urlImage.isEmpty || Uri.tryParse(urlImage)?.hasAbsolutePath != true) {
      return _buildPlaceholder();
    }

    return CachedNetworkImage(
      imageUrl: urlImage,
      fit: BoxFit.cover,
      memCacheWidth: 800,
      memCacheHeight: 800,
      maxWidthDiskCache: 1000,
      maxHeightDiskCache: 1000,
      placeholder: (context, url) => Container(
        color: Colors.grey[300],
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      errorWidget: (context, url, error) => _buildPlaceholder(),
      fadeInDuration: const Duration(milliseconds: 200),
      fadeOutDuration: const Duration(milliseconds: 150),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[300],
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_not_supported,
        size: 48,
        color: Colors.black54,
      ),
    );
  }

  Widget _buildTitleOverlay() {
    return Positioned(
      bottom: 8,
      left: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
