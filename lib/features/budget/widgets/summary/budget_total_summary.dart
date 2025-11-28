import 'package:flutter/material.dart';
import 'package:trip_planner/core/theme/text_style.dart';

class BudgetTotalSummary extends StatelessWidget {
  const BudgetTotalSummary({
    super.key,
    required this.totalExpense,
  });

  final double totalExpense;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              'Całkowity koszt podróży',
              style: AppTextStyles.heading2,
            ),
            const SizedBox(height: 12),
            Text(
              '${totalExpense.toStringAsFixed(2)} PLN',
              style: AppTextStyles.priceTextLarge,
            ),
          ],
        ),
      ),
    );
  }
}
