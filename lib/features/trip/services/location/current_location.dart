import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trip_planner/core/widgets/app_notifications.dart';

class CurrentLocation {
  static Future<Position?> getCurrentPosition({
    BuildContext? context,
  }) async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (context != null && context.mounted) {
        _showError(context,
            'Usługa lokalizacji (GPS) jest wyłączona. Włącz ją w ustawieniach.');
      }
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (context != null && context.mounted) {
          _showError(context, 'Nie udzielono uprawnień do lokalizacji.');
        }
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (context != null && context.mounted) {
        _showError(
          context,
          'Uprawnienia do lokalizacji są trwale odrzucone. '
          'Włącz je w ustawieniach aplikacji.',
        );
      }
      return null;
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (e) {
      if (context != null && context.mounted) {
        _showError(context,
            'Nie udało się pobrać lokalizacji. Sprawdź połączenie z GPS.');
      }
      return null;
    }
  }

  static Future<CameraPosition> getCameraPosition({
    BuildContext? context,
    double zoom = 14,
    LatLng fallback = const LatLng(52.237049, 21.017532),
  }) async {
    final position = await getCurrentPosition(context: context);

    if (position != null) {
      return CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: zoom,
      );
    }

    return CameraPosition(target: fallback, zoom: zoom);
  }

  static Marker currentLocationMarker(Position position) {
    return Marker(
      markerId: const MarkerId('currentLocation'),
      position: LatLng(position.latitude, position.longitude),
      infoWindow: const InfoWindow(title: 'Twoja lokalizacja'),
    );
  }

  static void _showError(BuildContext context, String message) {
    if (!context.mounted) return;
    AppNotifications.showError(
      context: context,
      message: message,
    );
  }
}
