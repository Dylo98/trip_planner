import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Model reprezentujący miejsce z Google Places API
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
    if (types.contains('church') || types.contains('place_of_worship')) {
      return '⛪';
    }
    if (types.contains('shopping_mall') || types.contains('store')) {
      return '🛍️';
    }
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

class OpeningHoursStatus {
  final bool openNow;

  OpeningHoursStatus({required this.openNow});
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
