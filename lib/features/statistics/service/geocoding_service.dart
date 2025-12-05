import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GeocodingService {
  static final String _googleApiKey = dotenv.env['GOOGLE_GEOCODING_API_KEY']!;

  static const String _nominatimBaseUrl = 'https://nominatim.openstreetmap.org';

  static Future<String?> getCityFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json'
        '?latlng=$latitude,$longitude'
        '&key=$_googleApiKey'
        '&language=pl',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final result = data['results'][0];

          for (final component in result['address_components']) {
            final types = component['types'] as List;

            if (types.contains('locality')) {
              return component['long_name'];
            }
          }
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<String?> getCountryFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json'
        '?latlng=$latitude,$longitude'
        '&key=$_googleApiKey'
        '&language=pl',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final result = data['results'][0];

          for (final component in result['address_components']) {
            final types = component['types'] as List;

            if (types.contains('country')) {
              return component['long_name'];
            }
          }
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, Map<String, String?>>> batchGeocode(
    List<Map<String, double>> coordinates,
  ) async {
    final results = <String, Map<String, String?>>{};

    for (final coord in coordinates) {
      final lat = coord['lat']!;
      final lng = coord['lng']!;
      final key = '${lat}_$lng';

      final city = await getCityFromCoordinates(lat, lng);
      final country = await getCountryFromCoordinates(lat, lng);

      results[key] = {
        'city': city,
        'country': country,
      };

      await Future.delayed(const Duration(milliseconds: 100));
    }

    return results;
  }

  static Future<String?> _getCityFromNominatim(
    double latitude,
    double longitude,
  ) async {
    try {
      final url = Uri.parse(
        '$_nominatimBaseUrl/reverse?lat=$latitude&lon=$longitude&format=json&addressdetails=1',
      );

      final response = await http.get(
        url,
        headers: {'User-Agent': 'TripPlanner/1.0'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['address'];

        return address['city'] ??
            address['town'] ??
            address['village'] ??
            address['municipality'];
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<String?> getCityFromCoordinatesWithFallback(
    double latitude,
    double longitude,
  ) async {
    final googleCity = await getCityFromCoordinates(latitude, longitude);

    if (googleCity != null && googleCity.isNotEmpty) {
      return googleCity;
    }
    return await _getCityFromNominatim(latitude, longitude);
  }
}
