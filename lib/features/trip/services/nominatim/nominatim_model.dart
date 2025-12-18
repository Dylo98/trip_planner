import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Kategoria miejsca dla API Nominatim (OpenStreetMap)
enum NominatimPlaceCategory {
  attraction('Atrakcja', '🎭'),
  historic('Zabytek', '🏛️'),
  food('Gastronomia', '🍽️'),
  nature('Natura', '🌳'),
  culture('Kultura', '🎨'),
  unknown('Inne', '📍');

  final String displayName;
  final String emoji;

  const NominatimPlaceCategory(this.displayName, this.emoji);

  static NominatimPlaceCategory fromTags(Map<String, dynamic> tags) {
    if (tags.containsKey('tourism')) {
      final tourism = tags['tourism'] as String?;
      if (tourism == 'museum' || tourism == 'gallery') {
        return NominatimPlaceCategory.culture;
      }
      return NominatimPlaceCategory.attraction;
    }
    if (tags.containsKey('historic')) {
      return NominatimPlaceCategory.historic;
    }
    if (tags.containsKey('amenity')) {
      final amenity = tags['amenity'] as String?;
      if (amenity == 'restaurant' || amenity == 'cafe' || amenity == 'bar') {
        return NominatimPlaceCategory.food;
      }
    }
    if (tags.containsKey('natural') || tags.containsKey('leisure')) {
      return NominatimPlaceCategory.nature;
    }
    return NominatimPlaceCategory.unknown;
  }
}

class PlaceDetails {
  final String? description;
  final String? website;
  final String? phone;
  final String? openingHours;
  final String? wikipedia;
  final String? wikidata;
  final double? rating;

  PlaceDetails({
    this.description,
    this.website,
    this.phone,
    this.openingHours,
    this.wikipedia,
    this.wikidata,
    this.rating,
  });

  factory PlaceDetails.fromTags(Map<String, dynamic> tags) {
    return PlaceDetails(
      description: tags['description'] as String?,
      website: tags['website'] as String? ?? tags['contact:website'] as String?,
      phone: tags['phone'] as String? ?? tags['contact:phone'] as String?,
      openingHours: tags['opening_hours'] as String?,
      wikipedia: tags['wikipedia'] as String?,
      wikidata: tags['wikidata'] as String?,
    );
  }
}

class PlaceSuggestion {
  final String name;
  final LatLng location;
  final String? address;
  final String? photoReference;
  final double? importance;
  final NominatimPlaceCategory category;
  final PlaceDetails? details;

  const PlaceSuggestion({
    required this.name,
    required this.location,
    this.address,
    this.photoReference,
    this.importance,
    this.category = NominatimPlaceCategory.unknown,
    this.details,
  });

  String get categoryEmoji => category.emoji;

  bool get hasPhoto => photoReference != null && photoReference!.isNotEmpty;
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
