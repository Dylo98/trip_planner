import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:trip_planner/core/theme/colors.dart';
import 'package:trip_planner/features/trip/services/google_places/google_places_service.dart';

class PlaceCardImage extends StatelessWidget {
  const PlaceCardImage({
    super.key,
    required this.photoReference,
    this.height = 100,
  });

  final String? photoReference;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (photoReference != null) {
      final photoUrl = _buildPhotoUrl(photoReference!);

      if (photoUrl == null) {
        return _buildPlaceholder();
      }

      return CachedNetworkImage(
        imageUrl: photoUrl,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          height: height,
          color: AppColors.grey,
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: (context, url, error) => _buildPlaceholder(),
        memCacheWidth: 600,
        memCacheHeight: 400,
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade300,
            Colors.purple.shade300,
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.place,
          size: 48,
          color: Colors.white,
        ),
      ),
    );
  }

  String? _buildPhotoUrl(String photoReference) {
    final service = GooglePlacesService();
    return service.getPhotoUrl(photoReference, maxWidth: 600);
  }
}
