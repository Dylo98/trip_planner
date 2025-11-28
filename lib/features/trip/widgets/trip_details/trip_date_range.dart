import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trip_planner/core/theme/colors.dart';
import 'package:trip_planner/core/theme/text_style.dart';

class TripDateRange extends StatelessWidget {
  const TripDateRange({
    super.key,
    required this.startDate,
    this.endDate,
    this.onEditPressed,
    this.isEditable = false,
  });

  final DateTime? startDate;
  final DateTime? endDate;
  final VoidCallback? onEditPressed;
  final bool isEditable;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isEditable ? onEditPressed : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.limeSliceDark,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isEditable) ...[
              const Icon(
                Icons.edit_calendar,
                size: 18,
                color: AppColors.limeSliceDark,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              startDate != null
                  ? DateFormat('dd-MM-yyyy').format(startDate!)
                  : 'Brak daty',
              style: AppTextStyles.buttonText,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Icon(Icons.arrow_right, size: 24),
            ),
            Text(
              endDate != null
                  ? DateFormat('dd-MM-yyyy').format(endDate!)
                  : '...',
              style: AppTextStyles.buttonText,
            ),
            if (isEditable) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right,
                size: 18,
                color: AppColors.limeSliceDark,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
