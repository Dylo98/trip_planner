import 'package:flutter/material.dart';
import 'package:trip_planner/core/theme/button_style.dart';
import 'package:trip_planner/core/theme/colors.dart';
import 'package:trip_planner/core/theme/text_style.dart';

class TripPlanHeader extends StatelessWidget {
  final bool isOngoing;
  final bool isGenerating;
  final VoidCallback onAddNextDay;

  const TripPlanHeader({
    super.key,
    required this.isOngoing,
    required this.isGenerating,
    required this.onAddNextDay,
  });

  @override
  Widget build(BuildContext context) {
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
          Icon(Icons.calendar_month, color: AppColors.textPrimary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Plan podróży', style: AppTextStyles.heading3),
              ],
            ),
          ),
          if (isOngoing)
            GradientButton(
              onPressed: isGenerating ? null : onAddNextDay,
              icon: isGenerating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : const Icon(Icons.add, size: 18, color: Colors.black),
              child: const Text(
                'Dodaj dzień',
                style: AppTextStyles.bodyText,
              ),
            ),
        ],
      ),
    );
  }
}
