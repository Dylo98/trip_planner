import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trip_planner/features/trip/services/nominatim/nominatim.dart';

/// Główny serwis do wyszukiwania miejsc za pomocą Nominatim OpenStreetMap
///
/// Obsługuje:
/// - Wyszukiwanie tekstowe
/// - Wyszukiwanie strukturalne po komponentach adresu
class NominatimSearchService {
  static Future<List<PlaceSuggestion>> searchPlaces(
    String query, {
    http.Client? client,
  }) async {
    if (query.trim().isEmpty) return [];

    await NominatimConfig.ensureRateLimit();

    final httpClient = client ?? http.Client();
    final shouldCloseClient = client == null;

    final url = Uri.parse('${NominatimConfig.baseUrl}/search?'
        'q=${Uri.encodeComponent(query)}'
        '&format=json'
        '&addressdetails=1'
        '&limit=10'
        '&dedupe=1');

    try {
      final response = await httpClient.get(
        url,
        headers: {'User-Agent': NominatimConfig.userAgent},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) {
        return [];
      }

      final List results = json.decode(response.body);
      final suggestions = _convertToSuggestions(results);

      return _sortAndLimit(suggestions, limit: 5);
    } on http.ClientException {
      return [];
    } catch (e) {
      return [];
    } finally {
      if (shouldCloseClient) {
        httpClient.close();
      }
    }
  }

  static Future<List<PlaceSuggestion>> searchPlacesStructured({
    String? street,
    String? city,
    String? country,
    String? building,
    http.Client? client,
  }) async {
    await NominatimConfig.ensureRateLimit();

    final httpClient = client ?? http.Client();
    final shouldCloseClient = client == null;

    final params = <String, String>{
      'format': 'json',
      'addressdetails': '1',
      'limit': '5',
      'dedupe': '1',
    };

    if (street != null) params['street'] = street;
    if (city != null) params['city'] = city;
    if (country != null) params['country'] = country;
    if (building != null) params['building'] = building;

    final url = Uri.parse('${NominatimConfig.baseUrl}/search')
        .replace(queryParameters: params);

    try {
      final response = await httpClient.get(
        url,
        headers: {'User-Agent': NominatimConfig.userAgent},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) {
        return [];
      }

      final List results = json.decode(response.body);
      return _convertToSuggestions(results);
    } on http.ClientException {
      return [];
    } catch (e) {
      return [];
    } finally {
      if (shouldCloseClient) {
        httpClient.close();
      }
    }
  }

  static List<PlaceSuggestion> _convertToSuggestions(List results) {
    return results.map((place) {
      return PlaceSuggestion(
        name: place['display_name'] as String,
        location: LatLng(
          double.parse(place['lat']),
          double.parse(place['lon']),
        ),
        address: place['display_name'] as String,
        photoReference: null,
        importance: place['importance'] as double?,
      );
    }).toList();
  }

  static List<PlaceSuggestion> _sortAndLimit(
    List<PlaceSuggestion> suggestions, {
    required int limit,
  }) {
    suggestions.sort((a, b) {
      final impA = a.importance ?? 0.0;
      final impB = b.importance ?? 0.0;
      return impB.compareTo(impA);
    });

    return suggestions.take(limit).toList();
  }
}
