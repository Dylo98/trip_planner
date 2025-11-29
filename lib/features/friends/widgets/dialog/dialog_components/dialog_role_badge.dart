import 'package:flutter/material.dart';
import 'package:trip_planner/core/theme/colors.dart';
import 'package:trip_planner/core/theme/text_style.dart';
import 'package:trip_planner/features/friends/model/shared_trip_member_model.dart';

class DialogRoleBadge extends StatelessWidget {
  const DialogRoleBadge({
    super.key,
    required this.role,
  });

  final TripRole role;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.limeSliceDark;
    final text = role == TripRole.editor ? 'Edytor' : 'Widz';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: AppTextStyles.bodySmall.copyWith(color: color),
      ),
    );
  }
}
