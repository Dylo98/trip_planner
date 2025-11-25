import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:trip_planner/features/trip/services/google_places/google_places_models.dart';
import 'package:trip_planner/features/trip/services/google_places/google_places_service.dart';
import 'package:trip_planner/features/trip/widgets/nearby_places/place_details_bottom_sheet.dart';

class PlaceCard extends StatelessWidget {
  const PlaceCard({
    super.key,
    required this.place,
    required this.onPlaceSelected,
  });

  final GooglePlace place;
  final Function(GooglePlace) onPlaceSelected;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showPlaceDetails(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildImage(),
            Padding(
              padding: const EdgeInsets.all(8),
              child: _buildInfo(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showPlaceDetails(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => PlaceDetailsBottomSheet(
        place: place,
        onAddToTrip: () => onPlaceSelected(place),
      ),
    );
  }

  Widget _buildImage() {
    if (place.photoReference != null) {
      final photoUrl = _buildPhotoUrl(place.photoReference!);

      if (photoUrl == null) {
        return _buildPlaceholder();
      }

      return CachedNetworkImage(
        imageUrl: photoUrl,
        height: 100,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          height: 100,
          color: Colors.grey.shade200,
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
      height: 100,
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

  Widget _buildInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          place.name,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (place.rating != null) ...[
          const SizedBox(height: 4),
          _buildRating(context),
        ],
      ],
    );
  }

  Widget _buildRating(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.star,
          size: 14,
          color: Colors.amber.shade700,
        ),
        const SizedBox(width: 4),
        Text(
          place.rating!.toStringAsFixed(1),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
        ),
        if (place.userRatingsTotal != null) ...[
          const SizedBox(width: 2),
          Text(
            '(${place.userRatingsTotal})',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                  fontSize: 10,
                ),
          ),
        ],
      ],
    );
  }

  String? _buildPhotoUrl(String photoReference) {
    final service = GooglePlacesService();
    return service.getPhotoUrl(photoReference, maxWidth: 600);
  }
}
