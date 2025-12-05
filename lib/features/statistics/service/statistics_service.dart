import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trip_planner/features/trip/model/trip_model.dart';
import 'package:trip_planner/features/trip/model/marker_point_model.dart';
import 'package:trip_planner/features/statistics/model/traveler_statistics.dart';
import 'dart:math' as math;

class StatisticsService {
  static TravelerStatistics calculateStatisticsSync(List<Trip> trips) {
    if (trips.isEmpty) {
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

    final allMarkers = <MarkerPoint>[];
    int totalDays = 0;
    double totalExpenses = 0;
    final transportModes = <String, int>{};

    for (final trip in trips) {
      allMarkers.addAll(trip.markerPoints);

      if (trip.startDate != null && trip.endDate != null) {
        totalDays += trip.endDate!.difference(trip.startDate!).inDays + 1;
      } else if (trip.startDate != null) {
        totalDays += 1;
      }

      for (final marker in trip.markerPoints) {
        totalExpenses += marker.totalExpense;

        if (marker.transportMode != null) {
          transportModes[marker.transportMode!] =
              (transportModes[marker.transportMode!] ?? 0) + 1;
        }
      }
    }

    final placesByCountry = _groupPlacesByCountryOffline(allMarkers);

    final citiesByCountry = <String, List<CityVisit>>{};

    final countriesVisitCount = <String, int>{};
    for (final country in placesByCountry.keys) {
      countriesVisitCount[country] = placesByCountry[country]!.length;
    }

    String mostVisitedCountry = '';
    int maxVisits = 0;
    for (final entry in countriesVisitCount.entries) {
      if (entry.value > maxVisits) {
        maxVisits = entry.value;
        mostVisitedCountry = entry.key;
      }
    }

    String favoriteTransportMode = '';
    int maxTransportCount = 0;
    for (final entry in transportModes.entries) {
      if (entry.value > maxTransportCount) {
        maxTransportCount = entry.value;
        favoriteTransportMode = entry.key;
      }
    }

    final totalDistance = _calculateTotalDistance(trips);

    return TravelerStatistics(
      totalTrips: trips.length,
      totalCountries: countriesVisitCount.length,
      totalCities: 0,
      totalPlaces: allMarkers.length,
      totalDistance: totalDistance,
      totalDays: totalDays,
      mostVisitedCountry: mostVisitedCountry,
      countriesVisitCount: countriesVisitCount,
      citiesByCountry: citiesByCountry,
      placesByCountry: placesByCountry,
      totalExpenses: totalExpenses,
      favoriteTransportMode: favoriteTransportMode,
    );
  }

  static Map<String, List<PlaceVisit>> _groupPlacesByCountryOffline(
    List<MarkerPoint> markers,
  ) {
    final placesByCountry = <String, List<PlaceVisit>>{};

    for (final marker in markers) {
      final country = _getFallbackCountry(
        marker.position.latitude,
        marker.position.longitude,
      );

      final placeName = marker.name ?? 'Nieznane miejsce';

      final placeVisit = PlaceVisit(
        placeName: placeName,
        latitude: marker.position.latitude,
        longitude: marker.position.longitude,
      );

      if (!placesByCountry.containsKey(country)) {
        placesByCountry[country] = [];
      }
      placesByCountry[country]!.add(placeVisit);
    }

    return placesByCountry;
  }

  static String _getFallbackCountry(double lat, double lng) {
    if (lat >= 49 && lat <= 54.5 && lng >= 14 && lng <= 24) {
      return 'Polska';
    } else if (lat >= 47 && lat <= 55 && lng >= 5.5 && lng <= 15.5) {
      return 'Niemcy';
    } else if (lat >= 42 && lat <= 51.5 && lng >= -5.5 && lng <= 10) {
      return 'Francja';
    } else if (lat >= 35 && lat <= 47.5 && lng >= 6 && lng <= 19) {
      return 'Włochy';
    } else if (lat >= 36 && lat <= 44 && lng >= -9.5 && lng <= 3.5) {
      return 'Hiszpania';
    } else if (lat >= 50 && lat <= 59 && lng >= -8 && lng <= 2) {
      return 'Wielka Brytania';
    } else if (lat >= 48.5 && lat <= 51.5 && lng >= 12 && lng <= 19) {
      return 'Czechy';
    } else if (lat >= 46 && lat <= 49.5 && lng >= 12 && lng <= 17) {
      return 'Austria';
    } else if (lat >= 45 && lat <= 48 && lng >= 5.5 && lng <= 11) {
      return 'Szwajcaria';
    } else if (lat >= 55 && lat <= 71 && lng >= 4 && lng <= 32) {
      return 'Skandynawia';
    } else if (lat >= 44 && lat <= 53 && lng >= 20 && lng <= 41) {
      return 'Europa Wschodnia';
    } else if (lat >= 37 && lat <= 42 && lng >= 19 && lng <= 29) {
      return 'Grecja';
    } else if (lat >= 37 && lat <= 42 && lng >= -10 && lng <= -6) {
      return 'Portugalia';
    } else if (lat >= 43 && lat <= 52 && lng >= 2 && lng <= 7.5) {
      return 'Belgia lub Holandia';
    } else if (lat >= 41 && lat <= 48 && lng >= 19 && lng <= 30) {
      return 'Rumunia lub Bułgaria';
    } else if (lat >= 25 && lat <= 49 && lng >= -125 && lng <= -66) {
      return 'USA';
    } else if (lat >= 42 && lat <= 84 && lng >= -141 && lng <= -52) {
      return 'Kanada';
    } else if (lat >= 14 && lat <= 33 && lng >= -118 && lng <= -86) {
      return 'Meksyk';
    } else if (lat >= -34 && lat <= 6 && lng >= -74 && lng <= -34) {
      return 'Brazylia';
    } else if (lat >= -56 && lat <= -22 && lng >= -74 && lng <= -53) {
      return 'Argentyna';
    } else if (lat >= -18 && lat <= -1 && lng >= -81 && lng <= -68) {
      return 'Peru';
    } else if (lat >= -5 && lat <= 13 && lng >= -80 && lng <= -66) {
      return 'Kolumbia lub Wenezuela';
    } else if (lat >= -23 && lat <= -10 && lng >= -70 && lng <= -47) {
      return 'Boliwia lub Paragwaj';
    } else if (lat >= -56 && lat <= -17 && lng >= -76 && lng <= -66) {
      return 'Chile';
    } else if (lat >= 18 && lat <= 54 && lng >= 73 && lng <= 135) {
      return 'Chiny';
    } else if (lat >= 24 && lat <= 46 && lng >= 123 && lng <= 154) {
      return 'Japonia';
    } else if (lat >= 33 && lat <= 43 && lng >= 124 && lng <= 132) {
      return 'Korea Południowa';
    } else if (lat >= 8 && lat <= 37 && lng >= 68 && lng <= 97) {
      return 'Indie';
    } else if (lat >= -11 && lat <= 6 && lng >= 95 && lng <= 141) {
      return 'Indonezja';
    } else if (lat >= 5 && lat <= 21 && lng >= 97 && lng <= 106) {
      return 'Tajlandia';
    } else if (lat >= 1 && lat <= 1.5 && lng >= 103.5 && lng <= 104.5) {
      return 'Singapur';
    } else if (lat >= 8 && lat <= 24 && lng >= 102 && lng <= 110) {
      return 'Wietnam';
    } else if (lat >= 10 && lat <= 26 && lng >= 92 && lng <= 102) {
      return 'Myanmar lub Laos';
    } else if (lat >= 23 && lat <= 26 && lng >= 119.5 && lng <= 122) {
      return 'Tajwan';
    } else if (lat >= 22 && lat <= 24 && lng >= 113 && lng <= 115) {
      return 'Hong Kong lub Makau';
    } else if (lat >= 1 && lat <= 7 && lng >= 99 && lng <= 105) {
      return 'Malezja';
    } else if (lat >= 12 && lat <= 18 && lng >= 99 && lng <= 108) {
      return 'Kambodża';
    } else if (lat >= 4 && lat <= 21 && lng >= 117 && lng <= 127) {
      return 'Filipiny';
    } else if (lat >= 36 && lat <= 42 && lng >= 26 && lng <= 45) {
      return 'Turcja';
    } else if (lat >= 22 && lat <= 32 && lng >= 34 && lng <= 48) {
      return 'Bliski Wschód';
    } else if (lat >= -44 && lat <= -10 && lng >= 113 && lng <= 154) {
      return 'Australia';
    } else if (lat >= -47 && lat <= -34 && lng >= 166 && lng <= 179) {
      return 'Nowa Zelandia';
    } else if (lat >= -25 && lat <= 0 && lng >= 130 && lng <= 180) {
      return 'Oceania';
    } else if (lat >= -35 && lat <= -22 && lng >= 16 && lng <= 33) {
      return 'Republika Południowej Afryki';
    } else if (lat >= 22 && lat <= 32 && lng >= 25 && lng <= 37) {
      return 'Egipt';
    } else if (lat >= -12 && lat <= 5 && lng >= 29 && lng <= 42) {
      return 'Afryka Wschodnia';
    } else if (lat >= 4 && lat <= 16 && lng >= -18 && lng <= 16) {
      return 'Afryka Zachodnia';
    } else if (lat >= -26 && lat <= 38 && lng >= -18 && lng <= 52) {
      return 'Afryka';
    } else if (lat >= 41 && lat <= 82 && lng >= 19 && lng <= 180) {
      return 'Rosja';
    }

    return 'Inne';
  }

  static double _calculateTotalDistance(List<Trip> trips) {
    double totalDistance = 0;

    for (final trip in trips) {
      final markers = trip.markerPoints;
      for (int i = 0; i < markers.length - 1; i++) {
        totalDistance += _calculateDistance(
          markers[i].position,
          markers[i + 1].position,
        );
      }
    }

    return totalDistance;
  }

  static double _calculateDistance(LatLng start, LatLng end) {
    const earthRadius = 6371.0;

    final dLat = _toRadians(end.latitude - start.latitude);
    final dLng = _toRadians(end.longitude - start.longitude);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(start.latitude)) *
            math.cos(_toRadians(end.latitude)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  static double _toRadians(double degrees) {
    return degrees * math.pi / 180;
  }
}
