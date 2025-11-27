import 'package:flutter/material.dart';
import 'package:trip_planner/core/theme/text_style.dart';
import 'package:trip_planner/features/schedule/widgets/dialog/dialog_components/dialog_category_icon.dart';
import 'package:trip_planner/features/schedule/utils/activity_icon_map.dart';

class DialogCategorySection extends StatelessWidget {
  final String? selectedIcon;
  final Function(String?) onIconSelected;

  const DialogCategorySection({
    super.key,
    required this.selectedIcon,
    required this.onIconSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kategoria',
          style: AppTextStyles.heading3,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: ActivityIconMap.availableIcons.map((option) {
            final isSelected = selectedIcon == option.id;
            return DialogCategoryIcon(
              id: option.id!,
              icon: option.icon,
              label: option.label,
              isSelected: isSelected,
              onSelected: (selected) =>
                  onIconSelected(selected ? option.id : null),
            );
          }).toList(),
        ),
      ],
    );
  }
}
