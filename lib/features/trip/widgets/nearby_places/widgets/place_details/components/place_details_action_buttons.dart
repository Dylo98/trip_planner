import 'package:flutter/material.dart';
import 'package:trip_planner/core/theme/button_style.dart';
import 'package:trip_planner/core/theme/colors.dart';
import 'package:trip_planner/core/theme/text_style.dart';

class PlaceDetailsActionButtons extends StatelessWidget {
  const PlaceDetailsActionButtons({
    super.key,
    required this.onClose,
    required this.onAddToTrip,
    this.isLoading = false,
  });

  final VoidCallback onClose;
  final VoidCallback onAddToTrip;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: isLoading ? null : onClose,
          child: const Text(
            'Zamknij',
            style: AppTextStyles.bodySmallGreen,
          ),
        ),
        const SizedBox(width: 12),
        GradientButton(
          onPressed: isLoading ? null : onAddToTrip,
          icon: isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(AppColors.darkGrey),
                  ),
                )
              : const Icon(
                  Icons.add_location,
                  color: AppColors.darkGrey,
                ),
          child: Text(
            isLoading ? 'Dodawanie...' : 'Dodaj do trasy',
            style: AppTextStyles.buttonText,
          ),
        ),
      ],
    );
  }
}
