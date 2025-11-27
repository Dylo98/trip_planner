import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/features/schedule/model/day_plan_model.dart';
import 'package:trip_planner/features/schedule/services/day_plan_service.dart';
import 'package:trip_planner/features/trip/model/marker_point_model.dart';
import 'package:trip_planner/features/trip/providers/watch_trip_provider.dart';

final dayPlanServiceProvider = Provider<DayPlanService>((ref) {
  return DayPlanService();
});

final watchDayPlanProvider =
    StreamProvider.family<DayPlan, DayPlanParams>((ref, params) {
  final service = ref.watch(dayPlanServiceProvider);
  return service.watchDayPlan(params.tripId, params.date);
});

final watchAllDayPlansProvider =
    StreamProvider.family<List<DayPlan>, String>((ref, tripId) {
  final service = ref.watch(dayPlanServiceProvider);
  return service.watchAllDayPlans(tripId);
});

final markerByIdProvider =
    Provider.family<MarkerPoint?, MarkerAndTripId>((ref, params) {
  final tripAsync = ref.watch(watchTripProvider(params.tripId));

  return tripAsync.maybeWhen(
    data: (trip) {
      try {
        return trip.markerPoints.firstWhere(
          (m) => m.id == params.markerId,
        );
      } catch (e) {
        return null;
      }
    },
    orElse: () => null,
  );
});

class DayPlanParams {
  final String tripId;
  final DateTime date;

  DayPlanParams({
    required this.tripId,
    required this.date,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DayPlanParams &&
        other.tripId == tripId &&
        other.date.year == date.year &&
        other.date.month == date.month &&
        other.date.day == date.day;
  }

  @override
  int get hashCode => Object.hash(
        tripId,
        date.year,
        date.month,
        date.day,
      );
}

class MarkerAndTripId {
  final String tripId;
  final String markerId;

  MarkerAndTripId(this.tripId, this.markerId);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MarkerAndTripId &&
          runtimeType == other.runtimeType &&
          tripId == other.tripId &&
          markerId == other.markerId;

  @override
  int get hashCode => Object.hash(tripId, markerId);
}
