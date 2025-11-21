import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/features/trip/providers/get_trip_provider.dart';
import 'package:trip_planner/features/statistics/model/traveler_statistics.dart';
import 'package:trip_planner/features/statistics/service/statistics_service.dart';

final statisticsProvider = FutureProvider<TravelerStatistics>((ref) async {
  final trips = ref.watch(getTripProvider).value ?? [];
  return await StatisticsService.calculateStatistics(trips);
});
