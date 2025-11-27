import 'package:flutter/material.dart';
import 'package:trip_planner/core/theme/colors.dart';
import 'package:trip_planner/features/schedule/model/day_plan_item_model.dart';
import 'package:trip_planner/features/schedule/utils/activity_icon_map.dart';

class ActivityItemCardIcon extends StatelessWidget {
  final DayPlanItem item;

  const ActivityItemCardIcon({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final iconData = ActivityIconMap.getIcon(item.icon);

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.limeSliceDark.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        size: 20,
        color: AppColors.limeSliceDark,
      ),
    );
  }
}
