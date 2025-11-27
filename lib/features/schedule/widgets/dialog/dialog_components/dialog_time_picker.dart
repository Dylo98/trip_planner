import 'package:flutter/material.dart';
import 'package:trip_planner/core/theme/colors.dart';
import 'package:trip_planner/core/theme/input_style.dart';
import 'package:trip_planner/core/theme/text_style.dart';

class DialogTimePicker extends StatelessWidget {
  final String label;
  final TimeOfDay? time;
  final VoidCallback onTap;
  final bool canClear;
  final VoidCallback? onClear;

  const DialogTimePicker({
    super.key,
    required this.label,
    required this.time,
    required this.onTap,
    this.canClear = false,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final isEmpty = time == null;
    final text = isEmpty ? '' : time!.format(context);

    final decoration = AppInputStyle.inputDecoration(
      icon: Icons.access_time,
      labelText: '',
    ).copyWith(
      suffixIcon: (canClear && time != null && onClear != null)
          ? IconButton(
              icon: const Icon(Icons.clear, size: 18),
              onPressed: onClear,
            )
          : null,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall,
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: InputDecorator(
            isEmpty: isEmpty,
            decoration: decoration,
            child: Text(
              text,
              style: TextStyle(
                color: isEmpty ? AppColors.textSecondary : AppColors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
