import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class GooglePlacesService {
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/place';

  static final String _apiKey = dotenv.env['GOOGLE_PLACES_API_KEY']!;

  static const Duration _cacheExpiration = Duration(hours: 24);
  static const int _maxResultsPerQuery = 10;
  static const int _maxRadiusMeters = 2000;
  static const int _maxRequestsPerMinute = 10;
  static const int _maxRequestsPerDay = 200;

  static final List<DateTime> _requestTimestamps = [];
  static int _dailyRequestCount = 0;
  static DateTime? _lastResetDate;

  static double _totalCostToday = 0.0;
  static const double _costNearbySearch = 0.032;
  static const double _costPlaceDetails = 0.017;
  static const double _costPhoto = 0.007;

  static Future<List<GooglePlace>> getNearbyPlaces({
    required LatLng location,
    int radiusMeters = 1000,
    String? type,
    List<String>? types,
  }) async {
    if (radiusMeters > _maxRadiusMeters) {
      debugPrint('⚠️ Radius zbyt duży, ograniczam do $_maxRadiusMeters m');
      radiusMeters = _maxRadiusMeters;
    }

    final cacheKey =
        _generateCacheKey(location, radiusMeters, type ?? types?.join(','));
    final cachedData = await _getFromCache(cacheKey);
    if (cachedData != null) {
      debugPrint(
          '✅ Cache HIT - oszczędzono \$${_costNearbySearch.toStringAsFixed(3)}');
      return cachedData;
    }

    if (!await _canMakeRequest()) {
      debugPrint('❌ Przekroczono limit zapytań!');
      return [];
    }

    try {
      final queryParams = {
        'location': '${location.latitude},${location.longitude}',
        'radius': radiusMeters.toString(),
        'key': _apiKey,
        'fields':
            'place_id,name,geometry,types,rating,user_ratings_total,photos,vicinity,business_status',
      };

      if (type != null) {
        queryParams['type'] = type;
      } else if (types != null && types.isNotEmpty) {
        queryParams['keyword'] = types.join('|');
      }

      final url = Uri.parse('$_baseUrl/nearbysearch/json').replace(
        queryParameters: queryParams,
      );

      debugPrint(
          '🔍 Zapytanie Google Places: ${location.latitude},${location.longitude} r=${radiusMeters}m');

      final response = await http.get(url).timeout(
            const Duration(seconds: 10),
          );

      _recordRequest(_costNearbySearch);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          final results = (data['results'] as List)
              .take(_maxResultsPerQuery)
              .map((json) => GooglePlace.fromJson(json))
              .toList();

          await _saveToCache(cacheKey, results);

          debugPrint(
              '✅ Znaleziono ${results.length} miejsc (koszt: \$${_costNearbySearch.toStringAsFixed(3)})');
          return results;
        } else {
          debugPrint(
              '❌ API Error: ${data['status']} - ${data['error_message'] ?? 'Brak opisu'}');
          return [];
        }
      }

      debugPrint('❌ HTTP Error: ${response.statusCode}');
      return [];
    } catch (e) {
      debugPrint('❌ Exception: $e');
      return [];
    }
  }

  static Future<GooglePlaceDetails?> getPlaceDetails(String placeId) async {
    final cacheKey = 'details_$placeId';
    final cachedData = await _getDetailsFromCache(cacheKey);
    if (cachedData != null) {
      debugPrint(
          '✅ Details Cache HIT - oszczędzono \$${_costPlaceDetails.toStringAsFixed(3)}');
      return cachedData;
    }

    if (!await _canMakeRequest()) {
      debugPrint('❌ Przekroczono limit zapytań!');
      return null;
    }

    try {
      final url = Uri.parse('$_baseUrl/details/json').replace(
        queryParameters: {
          'place_id': placeId,
          'key': _apiKey,
          'language': 'pl',
        },
      );

      final response = await http.get(url).timeout(
            const Duration(seconds: 10),
          );

      _recordRequest(_costPlaceDetails);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        debugPrint('🌐 API STATUS: ${data['status']}');
        debugPrint(
            '📱 RAW PHONE: ${data['result']?['formatted_phone_number']}');
        debugPrint(
            '📱 RAW INTL PHONE: ${data['result']?['international_phone_number']}');
        debugPrint('🌐 RAW WEBSITE: ${data['result']?['website']}');

        if (data['status'] == 'OK') {
          final details = GooglePlaceDetails.fromJson(data['result']);
          await _saveDetailsToCache(cacheKey, details);

          debugPrint(
              '✅ Pobrano szczegóły (koszt: \$${_costPlaceDetails.toStringAsFixed(3)})');
          return details;
        }
      }

      return null;
    } catch (e) {
      debugPrint('❌ Exception: $e');
      return null;
    }
  }

  static String? getPhotoUrl(String photoReference, {int maxWidth = 400}) {
    if (photoReference.isEmpty) return null;

    _recordRequest(_costPhoto);

    return '$_baseUrl/photo?maxwidth=$maxWidth&photo_reference=$photoReference&key=$_apiKey';
  }

  static Future<bool> _canMakeRequest() async {
    final now = DateTime.now();
    if (_lastResetDate == null || !_isSameDay(_lastResetDate!, now)) {
      _dailyRequestCount = 0;
      _totalCostToday = 0.0;
      _lastResetDate = now;
      await _saveDailyStats();
    }

    if (_dailyRequestCount >= _maxRequestsPerDay) {
      debugPrint(
          '🚫 LIMIT DZIENNY: $_dailyRequestCount/$_maxRequestsPerDay (koszt dzisiaj: \$${_totalCostToday.toStringAsFixed(2)})');
      return false;
    }

    final oneMinuteAgo = now.subtract(const Duration(minutes: 1));
    _requestTimestamps.removeWhere((ts) => ts.isBefore(oneMinuteAgo));

    if (_requestTimestamps.length >= _maxRequestsPerMinute) {
      debugPrint(
          '🚫 RATE LIMIT: ${_requestTimestamps.length}/$_maxRequestsPerMinute zapytań/min');
      return false;
    }

    return true;
  }

  static void _recordRequest(double cost) {
    _requestTimestamps.add(DateTime.now());
    _dailyRequestCount++;
    _totalCostToday += cost;
    _saveDailyStats();

    debugPrint(
        '📊 Stats: ${_dailyRequestCount}/$_maxRequestsPerDay zapytań | \$${_totalCostToday.toStringAsFixed(3)} dzisiaj');
  }

  static String _generateCacheKey(LatLng location, int radius, String? type) {
    return 'places_${location.latitude.toStringAsFixed(4)}_${location.longitude.toStringAsFixed(4)}_${radius}_$type';
  }

  static Future<List<GooglePlace>?> _getFromCache(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(key);
      if (cached == null) return null;

      final data = json.decode(cached);
      final timestamp = DateTime.parse(data['timestamp']);

      if (DateTime.now().difference(timestamp) > _cacheExpiration) {
        await prefs.remove(key);
        return null;
      }

      return (data['places'] as List)
          .map((json) => GooglePlace.fromJson(json))
          .toList();
    } catch (e) {
      return null;
    }
  }

  static Future<void> _saveToCache(String key, List<GooglePlace> places) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = {
        'timestamp': DateTime.now().toIso8601String(),
        'places': places.map((p) => p.toJson()).toList(),
      };
      await prefs.setString(key, json.encode(data));
    } catch (e) {
      debugPrint('Cache save error: $e');
    }
  }

  static Future<GooglePlaceDetails?> _getDetailsFromCache(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(key);
      if (cached == null) return null;

      final data = json.decode(cached);
      final timestamp = DateTime.parse(data['timestamp']);

      if (DateTime.now().difference(timestamp) > _cacheExpiration) {
        await prefs.remove(key);
        return null;
      }

      return GooglePlaceDetails.fromJson(data['details']);
    } catch (e) {
      return null;
    }
  }

  static Future<void> _saveDetailsToCache(
      String key, GooglePlaceDetails details) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = {
        'timestamp': DateTime.now().toIso8601String(),
        'details': details.toJson(),
      };
      await prefs.setString(key, json.encode(data));
    } catch (e) {
      debugPrint('Cache save error: $e');
    }
  }

  static Future<void> _saveDailyStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('daily_request_count', _dailyRequestCount);
      await prefs.setDouble('total_cost_today', _totalCostToday);
      await prefs.setString(
          'last_reset_date', _lastResetDate?.toIso8601String() ?? '');
    } catch (e) {
      debugPrint('Stats save error: $e');
    }
  }

  static Future<void> loadDailyStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _dailyRequestCount = prefs.getInt('daily_request_count') ?? 0;
      _totalCostToday = prefs.getDouble('total_cost_today') ?? 0.0;
      final dateStr = prefs.getString('last_reset_date');
      if (dateStr != null && dateStr.isNotEmpty) {
        _lastResetDate = DateTime.parse(dateStr);
      }
    } catch (e) {
      debugPrint('Stats load error: $e');
    }
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static CostStatistics getCostStatistics() {
    return CostStatistics(
      dailyRequests: _dailyRequestCount,
      maxDailyRequests: _maxRequestsPerDay,
      totalCostToday: _totalCostToday,
      requestsPerMinute: _requestTimestamps.length,
      maxRequestsPerMinute: _maxRequestsPerMinute,
    );
  }

  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith('places_') || key.startsWith('details_')) {
          await prefs.remove(key);
        }
      }
      debugPrint('✅ Cache wyczyszczony');
    } catch (e) {
      debugPrint('Cache clear error: $e');
    }
  }
}

class GooglePlace {
  final String placeId;
  final String name;
  final LatLng location;
  final List<String> types;
  final double? rating;
  final int? userRatingsTotal;
  final String? photoReference;
  final String? vicinity;

  GooglePlace({
    required this.placeId,
    required this.name,
    required this.location,
    required this.types,
    this.rating,
    this.userRatingsTotal,
    this.photoReference,
    this.vicinity,
  });

  factory GooglePlace.fromJson(Map<String, dynamic> json) {
    final geometry = json['geometry'] as Map<String, dynamic>;
    final location = geometry['location'] as Map<String, dynamic>;

    String? photoRef;
    if (json['photos'] != null && (json['photos'] as List).isNotEmpty) {
      photoRef = json['photos'][0]['photo_reference'] as String?;
    }

    return GooglePlace(
      placeId: json['place_id'] as String,
      name: json['name'] as String,
      location: LatLng(
        (location['lat'] as num).toDouble(),
        (location['lng'] as num).toDouble(),
      ),
      types: (json['types'] as List?)?.cast<String>() ?? [],
      rating: (json['rating'] as num?)?.toDouble(),
      userRatingsTotal: json['user_ratings_total'] as int?,
      photoReference: photoRef,
      vicinity: json['vicinity'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'place_id': placeId,
      'name': name,
      'geometry': {
        'location': {
          'lat': location.latitude,
          'lng': location.longitude,
        },
      },
      'types': types,
      'rating': rating,
      'user_ratings_total': userRatingsTotal,
      'photos': photoReference != null
          ? [
              {'photo_reference': photoReference}
            ]
          : null,
      'vicinity': vicinity,
    };
  }

  String get categoryEmoji {
    if (types.contains('restaurant') || types.contains('food')) return '🍽️';
    if (types.contains('cafe')) return '☕';
    if (types.contains('bar') || types.contains('night_club')) return '🍺';
    if (types.contains('museum')) return '🏛️';
    if (types.contains('tourist_attraction')) return '🎭';
    if (types.contains('park')) return '🌳';
    if (types.contains('church') || types.contains('place_of_worship'))
      return '⛪';
    if (types.contains('shopping_mall') || types.contains('store'))
      return '🛍️';
    if (types.contains('lodging') || types.contains('hotel')) return '🏨';
    if (types.contains('point_of_interest')) return '📍';
    return '🗺️';
  }

  String get categoryName {
    if (types.contains('restaurant')) return 'Restauracja';
    if (types.contains('cafe')) return 'Kawiarnia';
    if (types.contains('bar')) return 'Bar';
    if (types.contains('museum')) return 'Muzeum';
    if (types.contains('tourist_attraction')) return 'Atrakcja';
    if (types.contains('park')) return 'Park';
    if (types.contains('church')) return 'Kościół';
    if (types.contains('shopping_mall')) return 'Centrum handlowe';
    if (types.contains('lodging')) return 'Nocleg';
    return 'Miejsce';
  }
}

class GooglePlaceDetails {
  final String name;
  final String? formattedAddress;
  final String? internationalPhoneNumber;
  final String? formattedPhoneNumber;
  final String? website;
  final String? url;
  final double? rating;
  final int? userRatingsTotal;
  final int? priceLevel;
  final String? editorialSummary;
  final List<String>? openingHours;
  final OpeningHoursStatus? openingHoursStatus;
  final List<PlaceReview>? reviews;
  final List<String>? photoReferences;
  final List<String>? types;

  GooglePlaceDetails({
    required this.name,
    this.formattedAddress,
    this.internationalPhoneNumber,
    this.formattedPhoneNumber,
    this.website,
    this.url,
    this.rating,
    this.userRatingsTotal,
    this.priceLevel,
    this.editorialSummary,
    this.openingHours,
    this.openingHoursStatus,
    this.reviews,
    this.photoReferences,
    this.types,
  });

  factory GooglePlaceDetails.fromJson(Map<String, dynamic> json) {
    List<String>? hours;
    OpeningHoursStatus? status;

    if (json['opening_hours'] != null) {
      final openingHours = json['opening_hours'] as Map<String, dynamic>;
      hours = (openingHours['weekday_text'] as List?)?.cast<String>();

      if (openingHours['open_now'] != null) {
        status = OpeningHoursStatus(
          openNow: openingHours['open_now'] as bool,
        );
      }
    }

    List<PlaceReview>? reviewsList;
    if (json['reviews'] != null) {
      reviewsList = (json['reviews'] as List)
          .take(3)
          .map((r) => PlaceReview.fromJson(r))
          .toList();
    }

    List<String>? photoRefs;
    if (json['photos'] != null) {
      photoRefs = (json['photos'] as List)
          .take(5)
          .map((p) => p['photo_reference'] as String)
          .toList();
    }

    String? summary;
    if (json['editorial_summary'] != null) {
      final editorialSummary =
          json['editorial_summary'] as Map<String, dynamic>;
      summary = editorialSummary['overview'] as String?;
    }

    return GooglePlaceDetails(
      name: json['name'] as String,
      formattedAddress: json['formatted_address'] as String?,
      internationalPhoneNumber: json['international_phone_number'] as String?,
      formattedPhoneNumber: json['formatted_phone_number'] as String?,
      website: json['website'] as String?,
      url: json['url'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      userRatingsTotal: json['user_ratings_total'] as int?,
      priceLevel: json['price_level'] as int?,
      editorialSummary: summary,
      openingHours: hours,
      openingHoursStatus: status,
      reviews: reviewsList,
      photoReferences: photoRefs,
      types: (json['types'] as List?)?.cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'formatted_address': formattedAddress,
      'international_phone_number': internationalPhoneNumber,
      'formatted_phone_number': formattedPhoneNumber,
      'website': website,
      'url': url,
      'rating': rating,
      'user_ratings_total': userRatingsTotal,
      'price_level': priceLevel,
      'editorial_summary':
          editorialSummary != null ? {'overview': editorialSummary} : null,
      'opening_hours': openingHours != null
          ? {
              'weekday_text': openingHours,
              'open_now': openingHoursStatus?.openNow,
            }
          : null,
      'reviews': reviews?.map((r) => r.toJson()).toList(),
      'photos':
          photoReferences?.map((ref) => {'photo_reference': ref}).toList(),
      'types': types,
    };
  }

  String? get phoneNumber => internationalPhoneNumber ?? formattedPhoneNumber;

  String get priceLevelString {
    if (priceLevel == null) return 'Brak informacji';
    return '€' * priceLevel!;
  }
}

class PlaceReview {
  final String authorName;
  final int rating;
  final String text;
  final String relativeTimeDescription;

  PlaceReview({
    required this.authorName,
    required this.rating,
    required this.text,
    required this.relativeTimeDescription,
  });

  factory PlaceReview.fromJson(Map<String, dynamic> json) {
    return PlaceReview(
      authorName: json['author_name'] as String,
      rating: json['rating'] as int,
      text: json['text'] as String,
      relativeTimeDescription: json['relative_time_description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'author_name': authorName,
      'rating': rating,
      'text': text,
      'relative_time_description': relativeTimeDescription,
    };
  }
}

class CostStatistics {
  final int dailyRequests;
  final int maxDailyRequests;
  final double totalCostToday;
  final int requestsPerMinute;
  final int maxRequestsPerMinute;

  CostStatistics({
    required this.dailyRequests,
    required this.maxDailyRequests,
    required this.totalCostToday,
    required this.requestsPerMinute,
    required this.maxRequestsPerMinute,
  });

  double get dailyUsagePercent => (dailyRequests / maxDailyRequests) * 100;
  double get rateUsagePercent =>
      (requestsPerMinute / maxRequestsPerMinute) * 100;
  int get remainingDailyRequests => maxDailyRequests - dailyRequests;

  String get costFormatted => '\$${totalCostToday.toStringAsFixed(3)}';

  bool get isNearDailyLimit => dailyUsagePercent >= 80;
  bool get isNearRateLimit => rateUsagePercent >= 80;
}

class OpeningHoursStatus {
  final bool openNow;

  OpeningHoursStatus({required this.openNow});
}
