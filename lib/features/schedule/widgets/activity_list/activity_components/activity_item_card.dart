import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/core/theme/colors.dart';
import 'package:trip_planner/core/theme/text_style.dart';
import 'package:trip_planner/features/schedule/model/day_plan_item_model.dart';
import 'package:trip_planner/features/schedule/widgets/activity_list/activity_components/activity_item_card_time.dart';
import 'package:trip_planner/features/schedule/widgets/activity_list/activity_components/activity_item_card_icon.dart';
import 'package:trip_planner/features/schedule/widgets/activity_list/activity_components/activity_item_card_location.dart';
import 'package:trip_planner/features/schedule/widgets/activity_list/activity_components/activity_item_card_duration.dart';
import 'package:trip_planner/features/schedule/widgets/activity_list/activity_components/activity_item_card_expense.dart';

class ActivityItemCard extends ConsumerWidget {
  final DayPlanItem item;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final String tripId;

  const ActivityItemCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onDelete,
    required this.tripId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: ValueKey(item.id),
        direction: DismissDirection.endToStart,
        confirmDismiss: (direction) => _showDeleteDialog(context),
        onDismissed: (direction) => onDelete(),
        background: _buildDismissBackground(),
        child: _buildCard(ref),
      ),
    );
  }

  Widget _buildDismissBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: AppColors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.delete, color: AppColors.white, size: 28),
          SizedBox(height: 4),
          Text(
            'Usuń',
            style: AppTextStyles.bodyText.copyWith(
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(WidgetRef ref) {
    return Card(
      color: AppColors.limeSlice,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ActivityItemCardTime(
                item: item,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildContentColumn(ref),
              ),
              Align(
                alignment: Alignment.center,
                child: Icon(
                  Icons.chevron_right,
                  color: AppColors.limeSliceDark,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentColumn(WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ActivityItemCardIcon(item: item),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                item.title,
                style: AppTextStyles.bodyLarge,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ActivityItemCardLocation(item: item, tripId: tripId),
        if (item.description != null && item.description!.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            item.description!,
            style: AppTextStyles.bodyTextSecondary,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            ActivityItemCardDuration(durationMinutes: item.durationMinutes),
            if (item.hasExpenses)
              ActivityItemCardExpense(totalExpense: item.totalExpense),
          ],
        ),
      ],
    );
  }

  Future<bool?> _showDeleteDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Usuń aktywność'),
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
  }
}
