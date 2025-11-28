import 'package:flutter/material.dart';
import 'package:trip_planner/core/theme/colors.dart';
import 'package:trip_planner/core/theme/text_style.dart';

class StartingLocationBanner extends StatelessWidget {
  const StartingLocationBanner({
    super.key,
    required this.onClose,
  });

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.limeSlice,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            color: AppColors.limeSliceDark,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Wyszukaj miejsce rozpoczęcia podróży',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.limeSliceDark),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.close,
              color: AppColors.limeSliceDark,
              size: 20,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}
