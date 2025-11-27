import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/features/trip/providers/watch_trip_provider.dart';
import 'package:trip_planner/features/schedule/controller/day_plan_provider.dart';
import 'package:trip_planner/features/trip/model/trip_model.dart';
import 'package:trip_planner/features/schedule/controller/schedule_days_controller.dart';
import 'package:trip_planner/features/schedule/widgets/days_list/days_list_header.dart';
import 'package:trip_planner/features/schedule/widgets/days_list/day_card.dart';
import 'package:trip_planner/features/schedule/model/day_plan_model.dart';

class DaysScheduleScreen extends ConsumerStatefulWidget {
  final String tripId;

  const DaysScheduleScreen({
    super.key,
    required this.tripId,
  });

  @override
  ConsumerState<DaysScheduleScreen> createState() =>
      _TripDetailsDayPlanScreenState();
}

class _TripDetailsDayPlanScreenState extends ConsumerState<DaysScheduleScreen> {
  late final ScheduleDaysController _controller;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _controller = ScheduleDaysController(
      ref: ref,
      tripId: widget.tripId,
    );
  }

  int _calculateDaysCount({
    required bool isOngoing,
    required DateTime startDate,
    required DateTime? endDate,
    required int dayPlansCount,
  }) {
    if (isOngoing) {
      return dayPlansCount;
    } else {
      final end = endDate ?? startDate;
      return end.difference(startDate).inDays + 1;
    }
  }

  DateTime _getDateForIndex({
    required int index,
    required bool isOngoing,
    required DateTime startDate,
    required List<DayPlan> dayPlans,
  }) {
    if (isOngoing) {
      final sortedPlans = List<DayPlan>.from(dayPlans)
        ..sort((a, b) => a.date.compareTo(b.date));
      return sortedPlans[index].date;
    } else {
      return startDate.add(Duration(days: index));
    }
  }

  DayPlan? _findDayPlan(DateTime date, List<DayPlan> dayPlans) {
    try {
      return dayPlans.firstWhere(
        (plan) =>
            plan.date.year == date.year &&
            plan.date.month == date.month &&
            plan.date.day == date.day,
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> _handleAddNextDay() async {
    setState(() => _isGenerating = true);
    await _controller.addNextDay(context);
    if (mounted) {
      setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tripAsync = ref.watch(watchTripProvider(widget.tripId));
    final dayPlansAsync = ref.watch(watchAllDayPlansProvider(widget.tripId));

    return Scaffold(
      body: tripAsync.when(
        data: (trip) {
          return dayPlansAsync.when(
            data: (dayPlans) => _buildDaysList(
              trip: trip,
              dayPlans: dayPlans,
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Błąd: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Błąd: $e')),
      ),
    );
  }

  Widget _buildDaysList({
    required Trip trip,
    required List<DayPlan> dayPlans,
  }) {
    final isOngoing = trip.tripType == TripType.ongoing;
    final days = _calculateDaysCount(
      isOngoing: isOngoing,
      startDate: trip.startDate!,
      endDate: trip.endDate,
      dayPlansCount: dayPlans.length,
    );

    return Column(
      children: [
        TripPlanHeader(
          isOngoing: isOngoing,
          isGenerating: _isGenerating,
          onAddNextDay: _handleAddNextDay,
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: days,
            itemBuilder: (context, index) {
              final date = _getDateForIndex(
                index: index,
                isOngoing: isOngoing,
                startDate: trip.startDate!,
                dayPlans: dayPlans,
              );

              final dayPlan = _findDayPlan(date, dayPlans);

              return DayPlanCard(
                date: date,
                dayNumber: index + 1,
                activityCount: dayPlan?.activityCount ?? 0,
                tripId: widget.tripId,
              );
            },
          ),
        ),
      ],
    );
  }
}
