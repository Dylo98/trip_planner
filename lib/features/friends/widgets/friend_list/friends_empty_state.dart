import 'package:flutter/material.dart';
import 'package:trip_planner/core/theme/colors.dart';
import 'package:trip_planner/core/theme/text_style.dart';

class FriendsEmptyState extends StatelessWidget {
  const FriendsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: AppColors.limeSliceDark,
          ),
          const SizedBox(height: 16),
          const Text(
            'Nie masz jeszcze znajomych',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: 8),
          Text(
            'Dodaj znajomych, aby dzielić się podróżami',
            style: AppTextStyles.bodyTextSecondary,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
