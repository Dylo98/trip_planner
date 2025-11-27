import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/core/theme/colors.dart';
import 'package:trip_planner/core/theme/text_style.dart';
import 'package:trip_planner/features/schedule/controller/day_plan_provider.dart';
import 'package:trip_planner/features/schedule/model/day_plan_item_model.dart';
import 'package:trip_planner/features/schedule/utils/activity_icon_map.dart';

class ChecklistItemCard extends ConsumerWidget {
  final DayPlanItem item;
  final String tripId;
  final DateTime date;
  final VoidCallback? onEdit;

  const ChecklistItemCard({
    super.key,
    required this.item,
    required this.tripId,
    required this.date,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Dismissible(
        key: ValueKey(item.id),
        direction: DismissDirection.endToStart,
        confirmDismiss: (direction) async {
          return await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Usuń'),
              content: Text('Czy na pewno chcesz usunąć "${item.title}"?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Anuluj'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Usuń'),
                ),
              ],
            ),
          );
        },
        onDismissed: (direction) async {
          final service = ref.read(dayPlanServiceProvider);
          await service.removeItemFromDayPlan(tripId, date, item.id);
        },
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: AppColors.red,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.delete,
            color: AppColors.white,
          ),
        ),
        child: Card(
          elevation: 4,
          color: AppColors.limeSlice,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () => _toggleCompletion(context, ref),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Checkbox(
                    value: item.isCompleted,
                    onChanged: (_) => _toggleCompletion(context, ref),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.limeSliceDark.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      ActivityIconMap.getChecklistIcon(item.icon),
                      size: 20,
                      color: AppColors.limeSliceDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: AppTextStyles.bodyText.copyWith(
                            decoration: item.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        if (item.description != null &&
                            item.description!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            item.description!,
                            style: AppTextStyles.bodyTextSecondary.copyWith(
                              decoration: item.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, size: 20),
                    color: AppColors.limeSliceDark,
                    onPressed: onEdit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _toggleCompletion(BuildContext context, WidgetRef ref) async {
    final service = ref.read(dayPlanServiceProvider);
    final updatedItem = item.copyWith(isCompleted: !item.isCompleted);
    await service.updateItemInDayPlan(tripId, date, updatedItem);
  }
}
