import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/features/trip/model/trip_model.dart';
import 'package:trip_planner/features/trip/providers/get_trip_provider.dart';
import 'package:trip_planner/features/friends/providers/friends_provider.dart';

final allTripsProvider = StreamProvider.autoDispose<List<Trip>>((ref) {
  final ownTripsAsync = ref.watch(getTripProvider);
  final sharedTripsAsync = ref.watch(sharedTripsProvider);

  return Stream.value([
    ...ownTripsAsync.value ?? [],
    ...sharedTripsAsync.value ?? [],
  ]);
});
