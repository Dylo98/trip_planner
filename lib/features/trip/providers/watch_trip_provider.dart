import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/features/trip/model/trip_model.dart';
import 'package:trip_planner/features/trip/services/trip_service.dart';

final watchTripProvider = StreamProvider.family<Trip, String>((ref, tripId) {
  final service = ref.watch(tripServiceProvider);
  return service.watchTrip(tripId);
});
