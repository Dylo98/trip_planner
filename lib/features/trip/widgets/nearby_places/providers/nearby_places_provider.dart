import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trip_planner/features/trip/services/google_places/google_places_models.dart';
import 'package:trip_planner/features/trip/services/google_places/google_places_service.dart';
import 'package:trip_planner/features/trip/widgets/nearby_places/models/place_category.dart';

class NearbyPlacesData {
  final List<GooglePlace> places;
  final CostStatistics? statistics;

  const NearbyPlacesData({
    required this.places,
    this.statistics,
  });

  NearbyPlacesData copyWith({
    List<GooglePlace>? places,
    CostStatistics? statistics,
  }) {
    return NearbyPlacesData(
      places: places ?? this.places,
      statistics: statistics ?? this.statistics,
    );
  }
}

final selectedCategoryProvider = StateProvider<PlaceCategory>(
  (ref) => PlaceCategory.all,
);

final googlePlacesServiceProvider = Provider<GooglePlacesService>(
  (ref) => GooglePlacesService(),
);

final nearbyPlacesProvider = FutureProvider.autoDispose
    .family<NearbyPlacesData, LatLng>((ref, position) async {
  final service = ref.watch(googlePlacesServiceProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);

  var places = await service.getNearbyPlaces(
    location: position,
    radiusMeters: 1500,
    types:
        selectedCategory != PlaceCategory.all ? selectedCategory.types : null,
  );

  if (places.isEmpty) {
    places = await service.getNearbyPlaces(
      location: position,
      radiusMeters: 5000,
      types:
          selectedCategory != PlaceCategory.all ? selectedCategory.types : null,
    );
  }

  final statistics = await service.getStatistics();

  return NearbyPlacesData(
    places: places,
    statistics: statistics,
  );
});

final placesCountProvider = Provider.autoDispose<int>((ref) {
  final placesAsync = ref.watch(
    nearbyPlacesProvider(LatLng(0, 0)),
  );

  return placesAsync.maybeWhen(
    data: (data) => data.places.length,
    orElse: () => 0,
  );
});
