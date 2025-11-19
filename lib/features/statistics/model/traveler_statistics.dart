class TravelerStatistics {
  final int totalTrips;
  final int totalCountries;
  final int totalCities;
  final int totalPlaces;
  final double totalDistance;
  final int totalDays;
  final String mostVisitedCountry;
  final Map<String, int> countriesVisitCount;
  final Map<String, List<CityVisit>> citiesByCountry;
  final Map<String, List<PlaceVisit>> placesByCountry;
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
}

class CityVisit {
  final String cityName;
  final double latitude;
  final double longitude;
  final DateTime? visitDate;

  const CityVisit({
    required this.cityName,
    required this.latitude,
    required this.longitude,
    this.visitDate,
  });
}

class PlaceVisit {
  final String placeName;
  final double latitude;
  final double longitude;
  final DateTime? visitDate;

  const PlaceVisit({
    required this.placeName,
    required this.latitude,
    required this.longitude,
    this.visitDate,
  });
}
