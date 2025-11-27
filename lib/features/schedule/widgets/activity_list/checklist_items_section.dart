import 'package:flutter/material.dart';
import 'package:trip_planner/core/theme/colors.dart';
import 'package:trip_planner/core/theme/text_style.dart';
import 'package:trip_planner/features/schedule/model/day_plan_item_model.dart';
import 'package:trip_planner/features/schedule/widgets/activity_list/checklist_item_card.dart';

class ChecklistItemsSection extends StatelessWidget {
  final List<DayPlanItem> items;
  final String tripId;
  final DateTime date;
  final Function(DayPlanItem) onEdit;

  const ChecklistItemsSection({
    super.key,
    required this.items,
    required this.tripId,
    required this.date,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final completed = items.where((item) => item.isCompleted).length;
    final total = items.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Checklista',
              style: AppTextStyles.heading3,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.borderPrimaryLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Zaliczone: $completed/$total',
                style: AppTextStyles.bodySmall,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...items.map((item) => ChecklistItemCard(
              key: ValueKey(item.id),
              item: item,
              tripId: tripId,
              date: date,
              onEdit: () => onEdit(item),
            )),
      ],
    );
  }
}
