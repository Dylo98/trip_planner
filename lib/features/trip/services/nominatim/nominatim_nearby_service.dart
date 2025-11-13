import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trip_planner/features/trip/services/nominatim/nominatim.dart';

/// Serwis odpowiedzialny za wyszukiwanie ciekawych miejsc w pobliżu danej lokalizacji
///
/// Używa Overpass API do wyszukiwania:
/// - Atrakcji turystycznych
/// - Miejsc historycznych
/// - Restauracji i kawiarni
class NominatimNearbyService {
  static Future<List<PlaceSuggestion>> getNearbyPlaces(
    LatLng position, {
    int radiusKm = 2,
  }) async {
    final radiusMeters = radiusKm * 1000;

    final query = _buildOverpassQuery(position, radiusMeters);
    final url = Uri.parse('${NominatimConfig.overpassUrl}?data=$query');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        return [];
      }

      final data = json.decode(response.body);
      final elements = data['elements'] as List;

      return await _processElements(elements);
    } catch (e) {
      return [];
    }
  }

  static String _buildOverpassQuery(LatLng position, int radiusMeters) {
    return '[out:json];'
        '('
        'node["tourism"](around:$radiusMeters,${position.latitude},${position.longitude});'
        'node["historic"](around:$radiusMeters,${position.latitude},${position.longitude});'
        'node["amenity"~"restaurant|cafe"](around:$radiusMeters,${position.latitude},${position.longitude});'
        'way["tourism"](around:$radiusMeters,${position.latitude},${position.longitude});'
        'way["historic"](around:$radiusMeters,${position.latitude},${position.longitude});'
        ');'
        'out center tags 20;';
  }

  static Future<List<PlaceSuggestion>> _processElements(List elements) async {
    final suggestions = <PlaceSuggestion>[];

    for (final element in elements) {
      final tags = element['tags'] as Map<String, dynamic>? ?? {};
      final name = tags['name'] as String?;

      if (name == null || name.isEmpty) continue;

      final coordinates = _extractCoordinates(element);
      if (coordinates == null) continue;

      final photoUrl = await NominatimImageService.getImageFromTags(tags);

      suggestions.add(PlaceSuggestion(
        name: name,
        location: coordinates,
        address: name,
        photoReference: photoUrl,
      ));
    }

    return suggestions;
  }

  static LatLng? _extractCoordinates(Map<String, dynamic> element) {
    try {
      double lat, lon;

      if (element['type'] == 'way' && element['center'] != null) {
        lat = element['center']['lat'] as double;
        lon = element['center']['lon'] as double;
      } else {
        lat = element['lat'] as double;
        lon = element['lon'] as double;
      }

      return LatLng(lat, lon);
    } catch (e) {
      return null;
    }
  }
}
