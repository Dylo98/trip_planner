import 'package:flutter/material.dart';
import 'package:trip_planner/core/theme/colors.dart';
import 'package:trip_planner/core/theme/text_style.dart';
import 'package:trip_planner/features/schedule/model/day_plan_item_model.dart';

class ActivityItemCardTime extends StatelessWidget {
  final DayPlanItem item;

  const ActivityItemCardTime({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            _formatTime(item.startTime),
            style: AppTextStyles.bodyText,
          ),
          if (item.endTime != null) ...[
            const SizedBox(height: 2),
            Icon(
              Icons.arrow_downward,
              size: 12,
              color: AppColors.limeSliceDark,
            ),
            const SizedBox(height: 2),
            Text(
              _formatTime(item.endTime!),
              style: AppTextStyles.bodyText,
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
