import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../model/marker_point_model.dart';

class TripMarkersNotifier extends StateNotifier<List<MarkerPoint>> {
  TripMarkersNotifier() : super([]);

  void addMarker(MarkerPoint marker) {
    state = [...state, marker];
  }

  void clear() {
    state = [];
  }

  List<Marker> toGoogleMarkers() {
    return state.map((marker) {
      return Marker(
        markerId: MarkerId(marker.id),
        position: marker.position,
        infoWindow: InfoWindow(title: marker.name ?? 'Punkt'),
      );
    }).toList();
  }
}
