import 'dart:convert';
import 'package:http/http.dart' as http;

class GeocodingService {
  static const String _baseUrl = 'https://nominatim.openstreetmap.org';

  static Future<String?> getCityFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/reverse?lat=$latitude&lon=$longitude&format=json&addressdetails=1',
      );

      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'TripPlanner/1.0',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['address'];

        return address['city'] ??
            address['town'] ??
            address['village'] ??
            address['municipality'] ??
            address['county'] ??
            null;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, String?>> getBulkCities(
    List<Map<String, double>> coordinates,
  ) async {
    final results = <String, String?>{};

    for (final coord in coordinates) {
      final lat = coord['lat']!;
      final lng = coord['lng']!;
      final key = '${lat}_$lng';

      final city = await getCityFromCoordinates(lat, lng);
      results[key] = city;

      await Future.delayed(const Duration(seconds: 1));
    }

    return results;
  }
}
