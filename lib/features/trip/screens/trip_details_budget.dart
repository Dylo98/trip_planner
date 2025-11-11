import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/features/trip/controller/watch_trip_provider.dart';

class TripDetailsBudgetScreen extends ConsumerWidget {
  final String tripId;

  const TripDetailsBudgetScreen({super.key, required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripAsync = ref.watch(watchTripProvider(tripId));

    return Scaffold(
      body: tripAsync.when(
        data: (trip) {
          final markers = trip.markerPoints;

          double totalExpense = 0;
          final expensesByLocation = <String, double>{};

          for (final marker in markers) {
            if (marker.expense != null && marker.expense! > 0) {
              totalExpense += marker.expense!;
              final locationName = marker.name ?? 'Nieznane miejsce';
              expensesByLocation[locationName] = marker.expense!;
            }
          }

          if (totalExpense == 0) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.account_balance_wallet_outlined,
                      size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Brak wydatków',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Dodaj wydatki w szczegółach markerów',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 4,
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          const Text(
                            'Całkowity wydatek',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${totalExpense.toStringAsFixed(2)} PLN',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Na podstawie ${expensesByLocation.length} ${_getPlaceWord(expensesByLocation.length)}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Wydatki według miejsc',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...expensesByLocation.entries.map((entry) {
                    final percentage = (entry.value / totalExpense) * 100;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade100,
                          child: const Icon(Icons.place, color: Colors.blue),
                        ),
                        title: Text(
                          entry.key,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: percentage / 100,
                              backgroundColor: Colors.grey.shade200,
                              color: Colors.blue,
                            ),
                            const SizedBox(height: 4),
                            Text(
                                '${percentage.toStringAsFixed(1)}% całkowitego wydatku'),
                          ],
                        ),
                        trailing: Text(
                          '${entry.value.toStringAsFixed(2)} PLN',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Statystyki',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(),
                          _buildStatRow(
                            'Średni wydatek na miejsce',
                            '${(totalExpense / expensesByLocation.length).toStringAsFixed(2)} PLN',
                          ),
                          _buildStatRow(
                            'Najwyższy wydatek',
                            '${expensesByLocation.values.reduce((a, b) => a > b ? a : b).toStringAsFixed(2)} PLN',
                          ),
                          _buildStatRow(
                            'Najniższy wydatek',
                            '${expensesByLocation.values.reduce((a, b) => a < b ? a : b).toStringAsFixed(2)} PLN',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Błąd: $e')),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 15),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  String _getPlaceWord(int count) {
    if (count == 1) return 'miejsca';
    if (count % 10 >= 2 &&
        count % 10 <= 4 &&
        (count % 100 < 10 || count % 100 >= 20)) {
      return 'miejsca';
    }
    return 'miejsc';
  }
}
