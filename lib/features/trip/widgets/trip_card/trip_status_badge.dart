import 'package:flutter/material.dart';
import 'package:trip_planner/core/theme/colors.dart';
import 'package:trip_planner/core/theme/text_style.dart';
import 'package:trip_planner/features/trip/model/trip_model.dart';
import 'package:trip_planner/features/trip/utils/trip_status_helper.dart';

class TripStatusBadge extends StatelessWidget {
  const TripStatusBadge({
    super.key,
    required this.status,
  });

  final TripStatus status;

  @override
  Widget build(BuildContext context) {
    final statusHelper = TripStatusHelper(status);

    return Positioned(
      top: 12,
      left: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: statusHelper.color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.white,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              statusHelper.icon,
              color: AppColors.white,
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              statusHelper.label,
              style: AppTextStyles.bodySmallWhite,
            ),
          ],
        ),
      ),
    );
  }
}
