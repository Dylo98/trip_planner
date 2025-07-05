import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlaceSuggestion {
  final String name;
  final LatLng location;
  final String? address;
  final String? photoReference;

  PlaceSuggestion({
    required this.name,
    required this.location,
    this.address,
    this.photoReference,
  });
}

class PlaceSuggestionService {
  static Future<List<PlaceSuggestion>> fetchSuggestions(
    LatLng position,
    String apiKey,
  ) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json?'
      'location=${position.latitude},${position.longitude}'
      '&radius=1500'
      '&type=tourist_attraction&key=$apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List<dynamic>;

      return results.map((place) {
        final location = place['geometry']?['location'];
        final photo = place['photos'] != null && place['photos'].isNotEmpty
            ? place['photos'][0]['photo_reference']
            : null;

        return PlaceSuggestion(
          name: place['name'] as String,
          address: place['vicinity'] as String?,
          photoReference: photo,
          location: LatLng(
            location['lat'] as double,
            location['lng'] as double,
          ),
        );
      }).toList();
    } else {
      throw Exception('Failed to load suggestions');
    }
  }
}
