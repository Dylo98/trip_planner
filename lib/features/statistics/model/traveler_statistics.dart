/// Reprezentuje wizytę w lokalizacji (miasto lub miejsce)
class LocationVisit {
  final String name;
  final double latitude;
  final double longitude;
  final DateTime? visitDate;

  const LocationVisit({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.visitDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'visitDate': visitDate?.toIso8601String(),
    };
  }

  factory LocationVisit.fromJson(Map<String, dynamic> json) {
    return LocationVisit(
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      visitDate: json['visitDate'] != null
          ? DateTime.parse(json['visitDate'] as String)
          : null,
    );
  }

  LocationVisit copyWith({
    String? name,
    double? latitude,
    double? longitude,
    DateTime? visitDate,
  }) {
    return LocationVisit(
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      visitDate: visitDate ?? this.visitDate,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationVisit &&
        other.name == name &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode => name.hashCode ^ latitude.hashCode ^ longitude.hashCode;
}

/// Alias dla kompatybilności wstecznej
typedef CityVisit = LocationVisit;
typedef PlaceVisit = LocationVisit;

class TravelerStatistics {
  final int totalTrips;
  final int totalCountries;
  final int totalCities;
  final int totalPlaces;
  final double totalDistance;
  final int totalDays;
  final String mostVisitedCountry;
  final Map<String, int> countriesVisitCount;
  final Map<String, List<LocationVisit>> citiesByCountry;
  final Map<String, List<LocationVisit>> placesByCountry;
  final double totalExpenses;
  final String favoriteTransportMode;

  const TravelerStatistics({
    required this.totalTrips,
    required this.totalCountries,
    required this.totalCities,
    required this.totalPlaces,
    required this.totalDistance,
    required this.totalDays,
    required this.mostVisitedCountry,
    required this.countriesVisitCount,
    required this.citiesByCountry,
    required this.placesByCountry,
    required this.totalExpenses,
    required this.favoriteTransportMode,
  });

  factory TravelerStatistics.empty() {
    return const TravelerStatistics(
      totalTrips: 0,
      totalCountries: 0,
      totalCities: 0,
      totalPlaces: 0,
      totalDistance: 0,
      totalDays: 0,
      mostVisitedCountry: '',
      countriesVisitCount: {},
      citiesByCountry: {},
      placesByCountry: {},
      totalExpenses: 0,
      favoriteTransportMode: '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalTrips': totalTrips,
      'totalCountries': totalCountries,
      'totalCities': totalCities,
      'totalPlaces': totalPlaces,
      'totalDistance': totalDistance,
      'totalDays': totalDays,
      'mostVisitedCountry': mostVisitedCountry,
      'countriesVisitCount': countriesVisitCount,
      'citiesByCountry': citiesByCountry.map(
        (key, value) => MapEntry(key, value.map((v) => v.toJson()).toList()),
      ),
      'placesByCountry': placesByCountry.map(
        (key, value) => MapEntry(key, value.map((v) => v.toJson()).toList()),
      ),
      'totalExpenses': totalExpenses,
      'favoriteTransportMode': favoriteTransportMode,
    };
  }

  factory TravelerStatistics.fromJson(Map<String, dynamic> json) {
    return TravelerStatistics(
      totalTrips: json['totalTrips'] as int,
      totalCountries: json['totalCountries'] as int,
      totalCities: json['totalCities'] as int,
      totalPlaces: json['totalPlaces'] as int,
      totalDistance: (json['totalDistance'] as num).toDouble(),
      totalDays: json['totalDays'] as int,
      mostVisitedCountry: json['mostVisitedCountry'] as String,
      countriesVisitCount:
          Map<String, int>.from(json['countriesVisitCount'] as Map),
      citiesByCountry: (json['citiesByCountry'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          key,
          (value as List).map((v) => LocationVisit.fromJson(v)).toList(),
        ),
      ),
      placesByCountry: (json['placesByCountry'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          key,
          (value as List).map((v) => LocationVisit.fromJson(v)).toList(),
        ),
      ),
      totalExpenses: (json['totalExpenses'] as num).toDouble(),
      favoriteTransportMode: json['favoriteTransportMode'] as String,
    );
  }

  TravelerStatistics copyWith({
    int? totalTrips,
    int? totalCountries,
    int? totalCities,
    int? totalPlaces,
    double? totalDistance,
    int? totalDays,
    String? mostVisitedCountry,
    Map<String, int>? countriesVisitCount,
    Map<String, List<LocationVisit>>? citiesByCountry,
    Map<String, List<LocationVisit>>? placesByCountry,
    double? totalExpenses,
    String? favoriteTransportMode,
  }) {
    return TravelerStatistics(
      totalTrips: totalTrips ?? this.totalTrips,
      totalCountries: totalCountries ?? this.totalCountries,
      totalCities: totalCities ?? this.totalCities,
      totalPlaces: totalPlaces ?? this.totalPlaces,
      totalDistance: totalDistance ?? this.totalDistance,
      totalDays: totalDays ?? this.totalDays,
      mostVisitedCountry: mostVisitedCountry ?? this.mostVisitedCountry,
      countriesVisitCount: countriesVisitCount ?? this.countriesVisitCount,
      citiesByCountry: citiesByCountry ?? this.citiesByCountry,
      placesByCountry: placesByCountry ?? this.placesByCountry,
      totalExpenses: totalExpenses ?? this.totalExpenses,
      favoriteTransportMode:
          favoriteTransportMode ?? this.favoriteTransportMode,
    );
  }

  bool get hasTrips => totalTrips > 0;
  bool get hasExpenses => totalExpenses > 0;
  double get averageExpensePerTrip =>
      totalTrips > 0 ? totalExpenses / totalTrips : 0;
  double get averageDaysPerTrip => totalTrips > 0 ? totalDays / totalTrips : 0;
}
