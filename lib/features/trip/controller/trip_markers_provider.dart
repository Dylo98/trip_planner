import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/marker_point_model.dart';

class TripMarkersNotifier extends StateNotifier<List<MarkerPoint>> {
  TripMarkersNotifier() : super([]);

  void addMarker(MarkerPoint marker) {
    state = [...state, marker];
  }

  void clear() {
    state = [];
  }
}

final tripMarkersProvider =
    StateNotifierProvider<TripMarkersNotifier, List<MarkerPoint>>(
  (ref) => TripMarkersNotifier(),
);
