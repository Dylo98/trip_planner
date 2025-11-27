import 'package:flutter/material.dart';
import 'package:trip_planner/features/schedule/model/day_plan_item_model.dart';
import 'package:trip_planner/features/schedule/widgets/activity_list/activity_components/activity_item_card.dart';

class ActivityItemsList extends StatelessWidget {
  final List<DayPlanItem> items;
  final String tripId;
  final Function(DayPlanItem) onTap;
  final Function(DayPlanItem) onDelete;

  const ActivityItemsList({
    super.key,
    required this.items,
    required this.tripId,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items
          .map((item) => ActivityItemCard(
                key: ValueKey(item.id),
                item: item,
                tripId: tripId,
                onTap: () => onTap(item),
                onDelete: () => onDelete(item),
              ))
          .toList(),
    );
  }
}
