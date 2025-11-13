import 'package:flutter/material.dart';

class BudgetExpenseList extends StatelessWidget {
  const BudgetExpenseList({
    super.key,
    required this.expensesByLocation,
    required this.totalExpense,
  });

  final Map<String, double> expensesByLocation;
  final double totalExpense;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                  Text('${percentage.toStringAsFixed(1)}% całkowitego wydatku'),
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
      ],
    );
  }
}
