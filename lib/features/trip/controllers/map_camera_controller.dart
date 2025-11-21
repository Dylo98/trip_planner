import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Kontroler odpowiedzialny za zarządzanie kamerą mapy
class MapCameraController {
  GoogleMapController? _mapController;

  void setMapController(GoogleMapController controller) {
    _mapController = controller;
  }

  Future<void> animateToPosition(
    LatLng position, {
    double zoom = 15,
  }) async {
    await _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(position, zoom),
    );
  }

  Future<void> animateToBounds(LatLngBounds bounds) async {
    await _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 50),
    );
  }

  void dispose() {
    _mapController?.dispose();
  }
}
