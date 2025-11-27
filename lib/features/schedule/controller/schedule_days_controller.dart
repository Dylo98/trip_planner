import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/core/widgets/app_notifications.dart';
import 'package:trip_planner/features/schedule/controller/day_plan_provider.dart';
import 'package:trip_planner/features/trip/providers/watch_trip_provider.dart';

class ScheduleDaysController {
  final WidgetRef ref;
  final String tripId;

  ScheduleDaysController({
    required this.ref,
    required this.tripId,
  });

  Future<void> addNextDay(BuildContext context) async {
    if (!context.mounted) return;

    try {
      final trip = await ref.read(watchTripProvider(tripId).future);
      final service = ref.read(dayPlanServiceProvider);

      final allPlans = await service.getAllDayPlans(tripId);
      final DateTime nextDate;

      if (allPlans.isEmpty) {
        nextDate = trip.startDate ?? DateTime.now();
      } else {
        allPlans.sort((a, b) => a.date.compareTo(b.date));
        final lastDate = allPlans.last.date;
        nextDate = lastDate.add(const Duration(days: 1));
      }

      await service.generateEmptyPlansForTrip(tripId, nextDate, nextDate);

      if (context.mounted) {
        AppNotifications.showSuccess(
          context: context,
          message: 'Dodano dzień ${allPlans.length + 1}',
        );
      }
    } catch (e) {
      if (context.mounted) {
        AppNotifications.showError(
          context: context,
          message: 'Błąd podczas dodawania dnia: $e',
        );
      }
    }
  }
}
