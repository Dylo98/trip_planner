import 'package:flutter/material.dart';
import 'package:trip_planner/core/theme/colors.dart';
import 'package:trip_planner/core/theme/text_style.dart';
import 'package:trip_planner/core/theme/button_style.dart';

class ActivityItemsEmptyState extends StatelessWidget {
  final VoidCallback onAddActivity;

  const ActivityItemsEmptyState({
    super.key,
    required this.onAddActivity,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.schedule_outlined,
              size: 80,
              color: AppColors.grey,
            ),
            const SizedBox(height: 24),
            Text(
              'Brak zaplanowanych aktywności',
              style: AppTextStyles.bodyText,
            ),
            const SizedBox(height: 12),
            Text(
              'Dodaj pierwszą aktywność do swojego planu dnia',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyTextSecondary,
            ),
            const SizedBox(height: 32),
            GradientButton(
              onPressed: onAddActivity,
              child: const Text(
                'Dodaj aktywność',
                style: AppTextStyles.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
