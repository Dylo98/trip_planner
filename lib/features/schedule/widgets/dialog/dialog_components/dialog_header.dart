import 'package:flutter/material.dart';
import 'package:trip_planner/core/theme/colors.dart';
import 'package:trip_planner/core/theme/text_style.dart';

class DialogHeader extends StatelessWidget {
  final bool isEditing;
  final VoidCallback onClose;

  const DialogHeader({
    super.key,
    required this.isEditing,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
        border: Border(
          bottom: BorderSide(color: AppColors.borderPrimaryLight),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.schedule, color: AppColors.textPrimary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isEditing ? 'Edytuj aktywność' : 'Dodaj aktywność',
              style: AppTextStyles.heading3,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}
