import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CurrentLocation {
  static Future<Position> getCurrentPosition() async {
    await Geolocator.requestPermission();
    return await Geolocator.getCurrentPosition();
  }

  static Future<CameraPosition> getCameraPosition() async {
    final position = await getCurrentPosition();
    return CameraPosition(
        target: LatLng(position.latitude, position.longitude), zoom: 14);
  }

  static Marker currentLocationMarker(Position position) {
    return Marker(
      markerId: const MarkerId('currentLocation'),
      position: LatLng(position.latitude, position.longitude),
      infoWindow: const InfoWindow(title: 'Twoja lokalizacja'),
    );
  }
}
