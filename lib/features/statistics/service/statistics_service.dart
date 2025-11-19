import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trip_planner/features/trip/model/trip_model.dart';
import 'package:trip_planner/features/trip/model/marker_point_model.dart';
import 'package:trip_planner/features/statistics/model/traveler_statistics.dart';
import 'dart:math' as math;

class StatisticsService {
  static Future<TravelerStatistics> calculateStatistics(
    List<Trip> trips,
  ) async {
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
        if (marker.expenses != null) {
          for (final expense in marker.expenses!) {
            totalExpenses += expense.amount;
          }
        } else if (marker.expense != null) {
          totalExpenses += marker.expense!;
        }

        if (marker.transportMode != null) {
          transportModes[marker.transportMode!] =
              (transportModes[marker.transportMode!] ?? 0) + 1;
        }
      }
    }

    final placesByCountry = await _groupPlacesByCountry(allMarkers);

    final citiesByCountry = <String, List<CityVisit>>{};

    final countriesVisitCount = <String, int>{};
    for (final country in placesByCountry.keys) {
      countriesVisitCount[country] = 0;
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

  static Future<Map<String, List<PlaceVisit>>> _groupPlacesByCountry(
    List<MarkerPoint> markers,
  ) async {
    final placesByCountry = <String, List<PlaceVisit>>{};

    for (final marker in markers) {
      final country = await _getCountryFromCoordinates(
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

  static Future<String> _getCountryFromCoordinates(
    double lat,
    double lng,
  ) async {
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
