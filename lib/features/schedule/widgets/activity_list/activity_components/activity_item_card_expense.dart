import 'package:flutter/material.dart';
import 'package:trip_planner/core/theme/colors.dart';
import 'package:trip_planner/core/theme/text_style.dart';

class ActivityItemCardExpense extends StatelessWidget {
  final double totalExpense;

  const ActivityItemCardExpense({
    super.key,
    required this.totalExpense,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.account_balance_wallet,
            size: 14,
            color: AppColors.limeSliceDark,
          ),
          const SizedBox(width: 4),
          Text(
            '${totalExpense.toStringAsFixed(2)} PLN',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.limeSliceDark,
            ),
          ),
        ],
      ),
    );
  }
}
