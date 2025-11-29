import 'package:flutter/material.dart';
import 'package:trip_planner/core/theme/text_style.dart';
import 'package:trip_planner/features/friends/model/shared_trip_member_model.dart';

class DialogRoleSelector extends StatelessWidget {
  const DialogRoleSelector({
    super.key,
    required this.selectedRole,
    required this.onChanged,
  });

  final TripRole selectedRole;
  final ValueChanged<TripRole?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Uprawnienia',
          style: AppTextStyles.bodyText,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<TripRole>(
          isExpanded: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
          value: selectedRole,
          items: const [
            DropdownMenuItem(
              value: TripRole.editor,
              child: Text('Edytor', style: AppTextStyles.bodyText),
            ),
            DropdownMenuItem(
              value: TripRole.viewer,
              child: Text('Widz', style: AppTextStyles.bodyText),
            ),
          ],
          onChanged: onChanged,
        ),
      ],
    );
  }
}
