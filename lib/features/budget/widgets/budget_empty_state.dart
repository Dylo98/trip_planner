import 'package:flutter/material.dart';
import 'package:trip_planner/core/theme/colors.dart';
import 'package:trip_planner/core/theme/text_style.dart';

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
            color: AppColors.limeSliceDark,
          ),
          SizedBox(height: 16),
          Text(
            'Brak wydatków',
            style: AppTextStyles.heading3,
          ),
          SizedBox(height: 8),
          Text(
            'Dodaj wydatki w szczegółach markerów',
            style: AppTextStyles.bodyTextSecondary,
          ),
        ],
      ),
    );
  }
}
