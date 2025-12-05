import 'package:flutter/material.dart';
import 'package:trip_planner/core/theme/button_style.dart';
import 'package:trip_planner/core/widgets/empty_state.dart';

class BudgetEmptyState extends StatelessWidget {
  const BudgetEmptyState({
    super.key,
    required this.onAddPressed,
  });

  final VoidCallback onAddPressed;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const EmptyState(
          icon: Icons.account_balance_wallet_outlined,
          title: 'Brak wydatków',
          subtitle: 'Dodaj wydatki w szczegółach markerów',
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: GradientFAB(
            onPressed: onAddPressed,
            icon: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
