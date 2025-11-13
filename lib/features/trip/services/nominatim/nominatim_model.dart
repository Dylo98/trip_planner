import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlaceSuggestion {
  final String name;
  final LatLng location;
  final String? address;
  final String? photoReference;
  final double? importance;

  PlaceSuggestion({
    required this.name,
    required this.location,
    this.address,
    this.photoReference,
    this.importance,
  });
}

class NominatimConfig {
  static const String baseUrl = 'https://nominatim.openstreetmap.org';
  static const String overpassUrl = 'https://overpass-api.de/api/interpreter';
  static const String userAgent = 'TripPlanner/1.0 (contact: dawid.dyl2@wp.pl)';

  static DateTime? _lastRequestTime;
  static const Duration minRequestInterval = Duration(seconds: 1);

  static Future<void> ensureRateLimit() async {
    if (_lastRequestTime != null) {
      final timeSinceLastRequest = DateTime.now().difference(_lastRequestTime!);
      if (timeSinceLastRequest < minRequestInterval) {
        final waitTime = minRequestInterval - timeSinceLastRequest;
        await Future.delayed(waitTime);
      }
    }
    _lastRequestTime = DateTime.now();
  }
}
