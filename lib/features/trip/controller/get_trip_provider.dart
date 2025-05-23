import 'package:flutter_riverpod/flutter_riverpod.dart';

/* MODEL*/
import 'package:trip_planner/features/trip/model/trip_model.dart';
import 'package:trip_planner/features/trip/services/trip_service.dart';

final getTripProvider = StreamProvider<List<Trip>>((ref) {
  final tripService = ref.watch(tripServiceProvider);
  return tripService.getTrips();
});
