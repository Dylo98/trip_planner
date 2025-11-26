import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/features/trip/providers/watch_trip_provider.dart';
import 'package:trip_planner/features/timeline/widgets/timeline_list.dart';
import 'package:trip_planner/core/widgets/loading_indicator.dart';
import 'package:trip_planner/core/widgets/error_display.dart';
import 'package:trip_planner/core/widgets/empty_state.dart';

class TimelineScreen extends ConsumerWidget {
  final String tripId;

  const TimelineScreen({super.key, required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripAsync = ref.watch(watchTripProvider(tripId));

    return Scaffold(
      body: tripAsync.when(
        data: (trip) {
          final markers = trip.markerPoints;

          if (markers.isEmpty) {
            return const EmptyState(
              icon: Icons.timeline,
              title: 'Brak punktów na osi czasu',
              subtitle: 'Dodaj miejsca do swojej podróży',
            );
          }

          return TimelineList(
            markers: markers,
            tripId: tripId,
          );
        },
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorDisplay(error: e),
      ),
    );
  }
}
