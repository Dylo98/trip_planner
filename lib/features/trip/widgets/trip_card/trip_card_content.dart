import 'package:flutter/material.dart';
import 'package:trip_planner/core/theme/colors.dart';
import 'package:trip_planner/core/theme/text_style.dart';

class TripCardContent extends StatelessWidget {
  const TripCardContent({
    super.key,
    required this.tripName,
    required this.formattedStartDate,
    required this.totalBudget,
  });

  final String tripName;
  final String formattedStartDate;
  final double totalBudget;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildTripName(),
          const SizedBox(height: 4),
          _buildStartDate(),
          if (totalBudget > 0) ...[
            const SizedBox(height: 8),
            _buildBudget(),
          ],
        ],
      ),
    );
  }

  Widget _buildTripName() {
    return Text(
      tripName,
      style: AppTextStyles.tripCardTitle,
    );
  }

  Widget _buildStartDate() {
    return Text(
      formattedStartDate,
      style: AppTextStyles.tripCardDate,
    );
  }

  Widget _buildBudget() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.limeSliceDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.account_balance_wallet,
            color: AppColors.white,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            '${totalBudget.toStringAsFixed(2)} PLN',
            style: AppTextStyles.bodySmallWhite,
          ),
        ],
      ),
    );
  }
}
