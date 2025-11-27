import 'package:flutter/material.dart';
import 'package:trip_planner/core/theme/colors.dart';
import 'package:trip_planner/core/theme/text_style.dart';
import 'package:trip_planner/core/theme/button_style.dart';

class DialogActionsBar extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onConfirm;
  final bool isEditing;
  final String cancelLabel;
  final String addLabel;
  final String saveLabel;
  final bool isConfirmEnabled;

  const DialogActionsBar({
    super.key,
    required this.onCancel,
    required this.onConfirm,
    this.isEditing = false,
    this.cancelLabel = 'Anuluj',
    this.addLabel = 'Dodaj',
    this.saveLabel = 'Zapisz',
    this.isConfirmEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final primaryText = isEditing ? saveLabel : addLabel;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.borderLight),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: onCancel,
            child: Text(
              cancelLabel,
              style: AppTextStyles.buttonTextPrimary,
            ),
          ),
          const SizedBox(width: 12),
          GradientButton(
            onPressed: isConfirmEnabled ? onConfirm : null,
            child: Text(
              primaryText,
              style: AppTextStyles.buttonText,
            ),
          ),
        ],
      ),
    );
  }
}
