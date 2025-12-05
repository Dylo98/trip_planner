import 'package:flutter/material.dart';
import 'package:trip_planner/features/trip/services/google_places/google_places_models.dart';
import 'package:trip_planner/features/trip/widgets/nearby_places/widgets/place_card/place_card.dart';
import 'package:trip_planner/features/trip/widgets/nearby_places/widgets/places_grid/places_grid_empty_state.dart';

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
      return const PlacesGridEmptyState();
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
}
