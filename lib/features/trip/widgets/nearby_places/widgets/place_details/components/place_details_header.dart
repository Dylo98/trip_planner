import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:trip_planner/core/theme/colors.dart';
import 'package:trip_planner/features/trip/services/google_places/google_places_service.dart';

class PlaceDetailsHeader extends StatelessWidget {
  const PlaceDetailsHeader({
    super.key,
    this.photoUrl,
    this.photoReference,
    required this.categoryEmoji,
    this.height = 200,
  }) : assert(
            photoUrl != null || photoReference != null || categoryEmoji != '');

  final String? photoUrl;
  final String? photoReference;
  final String categoryEmoji;
  final double height;

  @override
  Widget build(BuildContext context) {
    String? finalPhotoUrl = photoUrl;

    if (finalPhotoUrl == null && photoReference != null) {
      final googlePlacesService = GooglePlacesService();
      finalPhotoUrl = googlePlacesService.getPhotoUrl(
        photoReference!,
        maxWidth: 600,
      );
    }

    if (finalPhotoUrl != null && finalPhotoUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: CachedNetworkImage(
          imageUrl: finalPhotoUrl,
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
          errorWidget: (context, error, stackTrace) => _buildEmojiHeader(),
        ),
      );
    } else {
      return _buildEmojiHeader();
    }
  }

  Widget _buildEmojiHeader() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade400,
            Colors.purple.shade400,
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Center(
        child: Text(
          categoryEmoji,
          style: const TextStyle(fontSize: 64),
        ),
      ),
    );
  }
}
