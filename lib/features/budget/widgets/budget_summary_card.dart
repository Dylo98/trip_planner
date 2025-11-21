import 'package:flutter/material.dart';

class BudgetSummaryCard extends StatelessWidget {
  const BudgetSummaryCard({
    super.key,
    required this.totalExpense,
    required this.locationCount,
    this.totalItems,
  });

  final double totalExpense;
  final int locationCount;
  final int? totalItems;

  String _getPlaceWord(int count) {
    if (count == 1) return 'miejsca';
    if (count % 10 >= 2 &&
        count % 10 <= 4 &&
        (count % 100 < 10 || count % 100 >= 20)) {
      return 'miejsca';
    }
    return 'miejsc';
  }

  String _getItemWord(int count) {
    if (count == 1) return 'wydatek';
    if (count % 10 >= 2 &&
        count % 10 <= 4 &&
        (count % 100 < 10 || count % 100 >= 20)) {
      return 'wydatki';
    }
    return 'wydatków';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
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
            if (totalItems != null && totalItems! > 0)
              Text(
                '$totalItems ${_getItemWord(totalItems!)} w $locationCount ${_getPlaceWord(locationCount)}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              )
            else
              Text(
                'Na podstawie $locationCount ${_getPlaceWord(locationCount)}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
