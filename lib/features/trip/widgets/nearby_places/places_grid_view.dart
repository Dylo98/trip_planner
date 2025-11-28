import 'package:flutter/material.dart';
import 'package:trip_planner/core/theme/colors.dart';
import 'package:trip_planner/core/theme/text_style.dart';
import 'package:trip_planner/features/trip/services/google_places/google_places_models.dart';
import 'package:trip_planner/features/trip/widgets/nearby_places/place_card.dart';

class PlacesGridView extends StatelessWidget {
  const PlacesGridView({
    super.key,
    required this.places,
    required this.onPlaceSelected,
  });

  final List<GooglePlace> places;
  final Function(GooglePlace) onPlaceSelected;

  @override
  Widget build(BuildContext context) {
    if (places.isEmpty) {
      return _buildEmptyState(context);
    }

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.5,
      ),
      child: GridView.builder(
        shrinkWrap: false,
        physics: const AlwaysScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        padding: const EdgeInsets.all(8),
        itemCount: places.length,
        itemBuilder: (context, index) {
          return PlaceCard(
            place: places[index],
            onPlaceSelected: onPlaceSelected,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.limeSliceDark,
            ),
            const SizedBox(height: 16),
            Text(
              'Nie znaleziono miejsc w tej kategorii',
              style: AppTextStyles.bodyText,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Spróbuj wybrać inną kategorię lub oddal widok mapy',
              style: AppTextStyles.bodyTextSecondary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
