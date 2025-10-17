import 'dart:async';
import 'dart:convert';
import 'dart:io';
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

    try {
      final response = await http.get(url).timeout(
            const Duration(seconds: 10),
          );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Sprawdź status Google API
        if (data['status'] == 'ZERO_RESULTS') {
          return [];
        }

        if (data['status'] != 'OK') {
          throw Exception('Google Places API error: ${data['status']}');
        }

        final results = data['results'] as List<dynamic>;

        return results
            .map((place) {
              final location = place['geometry']?['location'];
              if (location == null) return null;

              final photo =
                  place['photos'] != null && place['photos'].isNotEmpty
                      ? place['photos'][0]['photo_reference']
                      : null;

              return PlaceSuggestion(
                name: place['name'] as String? ?? 'Unknown',
                address: place['vicinity'] as String?,
                photoReference: photo,
                location: LatLng(
                  (location['lat'] as num).toDouble(),
                  (location['lng'] as num).toDouble(),
                ),
              );
            })
            .whereType<PlaceSuggestion>()
            .toList();
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } on TimeoutException {
      throw Exception('Request timeout - sprawdź połączenie');
    } on SocketException {
      throw Exception('Brak połączenia z internetem');
    } catch (e) {
      throw Exception('Failed to load suggestions: $e');
    }
  }
}
