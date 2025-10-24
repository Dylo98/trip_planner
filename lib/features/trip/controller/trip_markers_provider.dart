import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/features/trip/model/marker_point_model.dart';

class TripMarkersNotifier extends StateNotifier<List<MarkerPoint>> {
  TripMarkersNotifier() : super([]);

  void addMarker(MarkerPoint marker) {
    state = [...state, marker];
  }

  void removeMarker(String id) {
    state = state.where((marker) => marker.id != id).toList();
  }

  void updateMarkerTransport(String markerId, String transportMode) {
    state = state.map((marker) {
      if (marker.id == markerId) {
        return marker.copyWith(transportMode: transportMode);
      }
      return marker;
    }).toList();
  }

  void clear() {
    state = [];
  }
}

final tripMarkersProvider =
    StateNotifierProvider<TripMarkersNotifier, List<MarkerPoint>>((ref) {
  return TripMarkersNotifier();
});
