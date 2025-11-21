import 'package:flutter/material.dart';

class BudgetStatisticsCard extends StatelessWidget {
  const BudgetStatisticsCard({
    super.key,
    required this.averageExpense,
    required this.highestExpense,
    required this.lowestExpense,
  });

  final double averageExpense;
  final double highestExpense;
  final double lowestExpense;

  @override
  Widget build(BuildContext context) {
    return Card(
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
              '${averageExpense.toStringAsFixed(2)} PLN',
            ),
            _buildStatRow(
              'Najwyższy wydatek',
              '${highestExpense.toStringAsFixed(2)} PLN',
            ),
            _buildStatRow(
              'Najniższy wydatek',
              '${lowestExpense.toStringAsFixed(2)} PLN',
            ),
          ],
        ),
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
}
