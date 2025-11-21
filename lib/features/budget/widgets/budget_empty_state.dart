import 'package:flutter/material.dart';

class BudgetEmptyState extends StatelessWidget {
  const BudgetEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Brak wydatków',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
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
}
