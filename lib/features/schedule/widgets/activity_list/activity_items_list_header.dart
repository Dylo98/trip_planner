import 'package:flutter/material.dart';
import 'package:trip_planner/core/theme/colors.dart';
import 'package:trip_planner/core/theme/text_style.dart';
import 'package:trip_planner/features/schedule/model/day_plan_item_model.dart';

class ActivityItemsListHeader extends StatelessWidget {
  final List<DayPlanItem> scheduledItems;

  const ActivityItemsListHeader({
    super.key,
    required this.scheduledItems,
  });

  @override
  Widget build(BuildContext context) {
    if (scheduledItems.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(
            color: AppColors.divider,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.access_time,
            color: Colors.black,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Harmonogram dnia',
                style: AppTextStyles.heading3,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
