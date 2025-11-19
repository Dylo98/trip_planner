import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:trip_planner/features/trip/controller/watch_trip_provider.dart';
import 'package:trip_planner/features/trip/controller/day_plan_provider.dart';
import 'package:trip_planner/features/trip/model/trip_model.dart';
import 'package:trip_planner/features/trip/screens/day_plan_detail_screen.dart';

class TripDetailsDayPlanScreen extends ConsumerStatefulWidget {
  final String tripId;

  const TripDetailsDayPlanScreen({
    super.key,
    required this.tripId,
  });

  @override
  ConsumerState<TripDetailsDayPlanScreen> createState() =>
      _TripDetailsDayPlanScreenState();
}

class _TripDetailsDayPlanScreenState
    extends ConsumerState<TripDetailsDayPlanScreen> {
  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    final tripAsync = ref.watch(watchTripProvider(widget.tripId));
    final dayPlansAsync = ref.watch(watchAllDayPlansProvider(widget.tripId));

    return Scaffold(
      body: tripAsync.when(
        data: (trip) {
          if (trip.startDate == null) {
            return _buildNoDateState();
          }

          return dayPlansAsync.when(
            data: (dayPlans) {
              if (dayPlans.isEmpty && !_isGenerating) {
                return _buildEmptyState(trip.startDate!, trip.endDate);
              }

              return _buildDaysList(
                trip.startDate!,
                trip.endDate,
                dayPlans,
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Błąd: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Błąd: $e')),
      ),
    );
  }

  Widget _buildNoDateState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              'Brak dat podróży',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Ustaw daty podróży, aby móc planować dni',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(DateTime startDate, DateTime? endDate) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_note_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              'Brak planu podróży',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Wygeneruj plan dni, aby móc planować aktywności',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _isGenerating
                  ? null
                  : () => _generateDays(startDate, endDate),
              icon: _isGenerating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(_isGenerating ? 'Generowanie...' : 'Wygeneruj dni'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaysList(
    DateTime startDate,
    DateTime? endDate,
    List<dynamic> dayPlans,
  ) {
    final tripAsync = ref.watch(watchTripProvider(widget.tripId));
    final trip = tripAsync.value;
    final isOngoing = trip?.tripType == TripType.ongoing;

    final int days;
    if (isOngoing) {
      days = dayPlans.length;
    } else {
      final end = endDate ?? startDate;
      days = end.difference(startDate).inDays + 1;
    }

    if (days == 0) {
      return _buildEmptyState(startDate, endDate);
    }

    return Column(
      children: [
        _buildHeader(days, dayPlans.length),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: days,
            itemBuilder: (context, index) {
              final DateTime date;
              if (isOngoing) {
                final sortedPlans = List.from(dayPlans)
                  ..sort((a, b) => a.date.compareTo(b.date));
                date = sortedPlans[index].date;
              } else {
                date = startDate.add(Duration(days: index));
              }

              final dayPlan = dayPlans.cast<dynamic>().firstWhere(
                    (plan) =>
                        plan.date.year == date.year &&
                        plan.date.month == date.month &&
                        plan.date.day == date.day,
                    orElse: () => null,
                  );

              return _DayCard(
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

  Widget _buildHeader(int totalDays, int plannedDays) {
    final tripAsync = ref.watch(watchTripProvider(widget.tripId));
    final trip = tripAsync.value;
    final isOngoing = trip?.tripType == TripType.ongoing;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_month, color: Colors.blue.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOngoing ? 'Plan podróży (na bieżąco)' : 'Plan podróży',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
                Text(
                  isOngoing
                      ? '$totalDays ${totalDays == 1 ? "dzień" : "dni"} • $plannedDays z planami'
                      : '$totalDays dni • $plannedDays z planami',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          if (plannedDays == 0 && !isOngoing)
            ElevatedButton.icon(
              onPressed: _isGenerating ? null : () => _generateDays(null, null),
              icon: _isGenerating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add, size: 18),
              label: const Text('Generuj'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
          if (isOngoing)
            ElevatedButton.icon(
              onPressed: _isGenerating ? null : _addNextDay,
              icon: _isGenerating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add, size: 18),
              label: const Text('Dodaj dzień'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _addNextDay() async {
    setState(() => _isGenerating = true);

    try {
      final trip = await ref.read(watchTripProvider(widget.tripId).future);
      final service = ref.read(dayPlanServiceProvider);

      final allPlans = await service.getAllDayPlans(widget.tripId);
      final DateTime nextDate;

      if (allPlans.isEmpty) {
        nextDate = trip.startDate ?? DateTime.now();
      } else {
        allPlans.sort((a, b) => a.date.compareTo(b.date));
        final lastDate = allPlans.last.date;
        nextDate = lastDate.add(const Duration(days: 1));
      }

      await service.generateEmptyPlansForTrip(
        widget.tripId,
        nextDate,
        nextDate,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Dodano dzień ${allPlans.length + 1}'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Błąd: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  Future<void> _generateDays(DateTime? startDate, DateTime? endDate) async {
    setState(() => _isGenerating = true);

    try {
      final trip = await ref.read(watchTripProvider(widget.tripId).future);
      final service = ref.read(dayPlanServiceProvider);

      await service.generateEmptyPlansForTrip(
        widget.tripId,
        startDate ?? trip.startDate!,
        endDate ?? trip.endDate,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Wygenerowano plan dni'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Błąd: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }
}

class _DayCard extends StatelessWidget {
  final DateTime date;
  final int dayNumber;
  final int activityCount;
  final String tripId;

  const _DayCard({
    required this.date,
    required this.dayNumber,
    required this.activityCount,
    required this.tripId,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, d MMMM yyyy', 'pl_PL');
    final formattedDate = dateFormat.format(date);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DayPlanDetailScreen(
                tripId: tripId,
                date: date,
                dayNumber: dayNumber,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Dzień',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.blue.shade900,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '$dayNumber',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.blue.shade900,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.event_available,
                          size: 16,
                          color: activityCount > 0
                              ? Colors.green.shade700
                              : Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          activityCount > 0
                              ? '$activityCount ${activityCount == 1 ? "aktywność" : "aktywności"}'
                              : 'Brak aktywności',
                          style: TextStyle(
                            fontSize: 13,
                            color: activityCount > 0
                                ? Colors.green.shade700
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
