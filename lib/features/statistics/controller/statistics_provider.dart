import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/features/trip/providers/all_trips_provider.dart';
import 'package:trip_planner/features/statistics/model/traveler_statistics.dart';
import 'package:trip_planner/features/statistics/service/statistics_service.dart';

final statisticsProvider = Provider.autoDispose<TravelerStatistics>((ref) {
  final tripsAsync = ref.watch(allTripsProvider);

  return tripsAsync.when(
    data: (trips) {
      return StatisticsService.calculateStatisticsSync(trips);
    },
    loading: () {
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
    },
    error: (error, stackTrace) {
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
    },
  );
});
