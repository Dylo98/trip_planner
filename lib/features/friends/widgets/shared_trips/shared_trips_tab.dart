import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/core/utils/action_lock.dart';
import 'package:trip_planner/features/friends/controller/friends_provider.dart';
import 'package:trip_planner/features/friends/widgets/shared_trips/shared_trip_item.dart';
import 'package:trip_planner/features/friends/widgets/shared_trips/shared_trips_empty_state.dart';

class SharedTripsTab extends ConsumerStatefulWidget {
  const SharedTripsTab({super.key});

  @override
  ConsumerState<SharedTripsTab> createState() => _SharedTripsTabState();
}

class _SharedTripsTabState extends ConsumerState<SharedTripsTab> {
  final _openTripLock = ActionLock();

  @override
  Widget build(BuildContext context) {
    final sharedTripsAsync = ref.watch(sharedTripsProvider);

    return sharedTripsAsync.when(
      data: (trips) {
        if (trips.isEmpty) {
          return const SharedTripsEmptyState();
        }

        return ListView.builder(
          itemCount: trips.length,
          padding: const EdgeInsets.all(8),
          itemBuilder: (context, index) {
            final trip = trips[index];
            return SharedTripItem(
              trip: trip,
              openTripLock: _openTripLock,
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Błąd podczas ładowania podróży'),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => ref.invalidate(sharedTripsProvider),
              child: const Text('Spróbuj ponownie'),
            ),
          ],
        ),
      ),
    );
  }
}
