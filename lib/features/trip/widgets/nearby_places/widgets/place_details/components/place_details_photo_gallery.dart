import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:trip_planner/core/theme/colors.dart';
import 'package:trip_planner/features/trip/services/google_places/google_places_service.dart';
import 'package:trip_planner/features/trip/widgets/nearby_places/widgets/place_details/components/place_details_section_title.dart';

class PlaceDetailsPhotoGallery extends StatelessWidget {
  const PlaceDetailsPhotoGallery({
    super.key,
    required this.photoReferences,
  });

  final List<String> photoReferences;

  @override
  Widget build(BuildContext context) {
    final googlePlacesService = GooglePlacesService();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PlaceDetailsSectionTitle(title: 'Zdjęcia'),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: photoReferences.length,
            itemBuilder: (context, index) {
              final photoRef = photoReferences[index];
              final photoUrl =
                  googlePlacesService.getPhotoUrl(photoRef, maxWidth: 200);

              if (photoUrl == null) {
                return const SizedBox.shrink();
              }

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: photoUrl,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 100,
                      height: 100,
                      color: AppColors.limeSliceDark,
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 100,
                      height: 100,
                      color: AppColors.limeSliceDark,
                      child: const Icon(Icons.broken_image),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
