import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class TripPhotoGrid extends StatelessWidget {
  const TripPhotoGrid({
    super.key,
    required this.imageUrls,
  });

  final List<String> imageUrls;

  @override
  Widget build(BuildContext context) {
    return GridView.custom(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverQuiltedGridDelegate(
        crossAxisCount: 4,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        repeatPattern: QuiltedGridRepeatPattern.inverted,
        pattern: const [
          QuiltedGridTile(2, 2),
          QuiltedGridTile(1, 1),
          QuiltedGridTile(1, 1),
          QuiltedGridTile(1, 2),
        ],
      ),
      childrenDelegate: SliverChildBuilderDelegate(
        (context, index) => _buildPhotoTile(context, imageUrls[index]),
        childCount: imageUrls.length,
      ),
    );
  }

  Widget _buildPhotoTile(BuildContext context, String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: GestureDetector(
        onTap: () => _showFullscreenImage(context, imageUrl),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey[300],
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[300],
            child: const Icon(
              Icons.broken_image,
              size: 32,
              color: Colors.grey,
            ),
          ),
          memCacheWidth: 400,
          memCacheHeight: 400,
        ),
      ),
    );
  }

  void _showFullscreenImage(BuildContext context, String imageUrl) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Dismiss",
      barrierColor: Colors.black.withValues(alpha: 0.8),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => Center(
        child: InteractiveViewer(
          child: Image.network(imageUrl, fit: BoxFit.contain),
        ),
      ),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeScaleTransition(
          animation: animation,
          child: child,
        );
      },
    );
  }
}
