import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/features/schedule/model/day_plan_model.dart';
import 'package:trip_planner/features/schedule/services/day_plan_service.dart';

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
