import 'package:flutter/material.dart';
import 'package:trip_planner/core/theme/colors.dart';
import 'package:trip_planner/core/theme/text_style.dart';

class ActivityItemCardDuration extends StatelessWidget {
  final int durationMinutes;

  const ActivityItemCardDuration({
    super.key,
    required this.durationMinutes,
  });

  String _formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;

    if (hours > 0 && mins > 0) {
      return '${hours}h ${mins}min';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${mins}min';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.limeSlice,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer_outlined,
            size: 14,
            color: AppColors.limeSliceDark,
          ),
          const SizedBox(width: 4),
          Text(
            _formatDuration(durationMinutes),
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.limeSliceDark,
            ),
          ),
        ],
      ),
    );
  }
}
