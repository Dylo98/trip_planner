import 'package:flutter_riverpod/flutter_riverpod.dart';

/* AUTH */
import 'package:trip_planner/features/auth/controller/user_provider.dart';

/* MODEL */
import 'package:trip_planner/features/trip/model/trip_model.dart';

/* SERVICE */
import 'package:trip_planner/features/trip/services/trip_service.dart';

final getTripProvider = StreamProvider.autoDispose<List<Trip>>((ref) {
  final user = ref.watch(authStateProvider).value;
  final tripService = ref.watch(tripServiceProvider);
  if (user == null) {
    return Stream.value([]);
  }
  return tripService.getTrips(user.uid);
});
