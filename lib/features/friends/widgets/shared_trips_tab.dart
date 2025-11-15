import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/features/friends/controller/friends_provider.dart';
import 'package:trip_planner/features/trip/widgets/trip_card.dart';
import 'package:trip_planner/core/utils/action_lock.dart';

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
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.share_outlined,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Brak współdzielonych podróży',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tutaj zobaczysz podróże,\nktóre znajomi udostępnili Ci',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: trips.length,
          padding: const EdgeInsets.all(8),
          itemBuilder: (context, index) {
            final trip = trips[index];
            return Column(
              children: [
                TripCard(
                  trip: trip,
                  openTripLock: _openTripLock,
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.share, size: 14, color: Colors.blue),
                            SizedBox(width: 4),
                            Text(
                              'Współdzielona',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
