import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'google_places_models.dart';
import 'google_places_cache_manager.dart';
import 'google_places_rate_limiter.dart';

class GooglePlacesService {
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/place';
  static final String _apiKey = dotenv.env['GOOGLE_PLACES_API_KEY']!;

  static const int _maxResultsPerQuery = 10;
  static const int _maxRadiusMeters = 2000;

  final GooglePlacesCacheManager _cacheManager;
  final GooglePlacesRateLimiter _rateLimiter;

  GooglePlacesService({
    GooglePlacesCacheManager? cacheManager,
    GooglePlacesRateLimiter? rateLimiter,
  })  : _cacheManager = cacheManager ?? GooglePlacesCacheManager(),
        _rateLimiter = rateLimiter ?? GooglePlacesRateLimiter();

  Future<List<GooglePlace>> getNearbyPlaces({
    required LatLng location,
    int radiusMeters = 1000,
    String? type,
    List<String>? types,
  }) async {
    radiusMeters = radiusMeters.clamp(0, _maxRadiusMeters);

    final cacheKey =
        _generateCacheKey(location, radiusMeters, type ?? types?.join(','));

    final cachedData = await _cacheManager.getPlaces(cacheKey);
    if (cachedData != null) {
      return cachedData;
    }

    if (!await _rateLimiter.canMakeRequest()) {
      return [];
    }

    try {
      final response = await _fetchNearbyPlaces(
        location: location,
        radiusMeters: radiusMeters,
        type: type,
        types: types,
      );

      if (response == null) return [];

      final results = _parseNearbyPlacesResponse(response);

      await _cacheManager.savePlaces(cacheKey, results);

      _rateLimiter.recordRequest(GooglePlacesRateLimiter.costNearbySearch);

      return results;
    } catch (e) {
      return [];
    }
  }

  Future<GooglePlaceDetails?> getPlaceDetails(String placeId) async {
    final cachedData = await _cacheManager.getPlaceDetails(placeId);
    if (cachedData != null) {
      return cachedData;
    }

    if (!await _rateLimiter.canMakeRequest()) {
      return null;
    }

    try {
      final response = await _fetchPlaceDetails(placeId);
      if (response == null) return null;

      final details = GooglePlaceDetails.fromJson(response['result']);

      await _cacheManager.savePlaceDetails(placeId, details);

      _rateLimiter.recordRequest(0.008);
      return details;
    } catch (e) {
      return null;
    }
  }

  String? getPhotoUrl(String photoReference, {int maxWidth = 400}) {
    if (photoReference.isEmpty) return null;

    return '$_baseUrl/photo?maxwidth=$maxWidth&photo_reference=$photoReference&key=$_apiKey';
  }

  Future<CostStatistics> getStatistics() async {
    return _rateLimiter.getStatistics();
  }

  static Future<void> loadDailyStats() async {
    await GooglePlacesRateLimiter.loadDailyStats();
  }

  Future<Map<String, dynamic>?> _fetchNearbyPlaces({
    required LatLng location,
    required int radiusMeters,
    String? type,
    List<String>? types,
  }) async {
    final queryParams = {
      'location': '${location.latitude},${location.longitude}',
      'radius': radiusMeters.toString(),
      'key': _apiKey,
      'language': 'pl',
    };

    if (type != null) {
      queryParams['type'] = type;
    } else if (types != null && types.isNotEmpty) {
      queryParams['keyword'] = types.join('|');
    }

    final url = Uri.parse('$_baseUrl/nearbysearch/json')
        .replace(queryParameters: queryParams);

    final response = await http.get(url).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['status'] == 'OK') {
        return data;
      } else if (data['status'] == 'OVER_QUERY_LIMIT') {
      } else {}
    } else {}

    return null;
  }

  Future<Map<String, dynamic>?> _fetchPlaceDetails(String placeId) async {
    final url = Uri.parse('$_baseUrl/details/json').replace(
      queryParameters: {
        'place_id': placeId,
        'key': _apiKey,
        'language': 'pl',
        'fields': 'name,formatted_address,formatted_phone_number,'
            'international_phone_number,website,url,rating,user_ratings_total,'
            'price_level,editorial_summary,opening_hours,reviews,photos,types',
      },
    );

    final response = await http.get(url).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['status'] == 'OK') {
        return data;
      } else if (data['status'] == 'OVER_QUERY_LIMIT') {
      } else {}
    } else {}

    return null;
  }

  List<GooglePlace> _parseNearbyPlacesResponse(Map<String, dynamic> data) {
    return (data['results'] as List)
        .take(_maxResultsPerQuery)
        .map((json) => GooglePlace.fromJson(json))
        .toList();
  }

  String _generateCacheKey(LatLng location, int radius, String? type) {
    return 'places_${location.latitude.toStringAsFixed(4)}_${location.longitude.toStringAsFixed(4)}_${radius}_$type';
  }

  Future<void> clearCache() async {
    await _cacheManager.clearCache();
  }

  static Future<void> resetStatistics() async {
    await GooglePlacesRateLimiter.resetStatistics();
  }
}
