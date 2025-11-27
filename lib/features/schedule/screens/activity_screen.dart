import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:trip_planner/core/theme/button_style.dart';
import 'package:trip_planner/core/theme/colors.dart';
import 'package:trip_planner/features/schedule/controller/day_plan_provider.dart';
import 'package:trip_planner/features/schedule/controller/activity_controller.dart';
import 'package:trip_planner/features/schedule/widgets/activity_list/activity_items_list_header.dart';
import 'package:trip_planner/features/schedule/widgets/activity_list/activity_items_list.dart';
import 'package:trip_planner/features/schedule/widgets/activity_list/checklist_items_section.dart';
import 'package:trip_planner/features/schedule/widgets/activity_list/activity_items_empty_state.dart';
import 'package:trip_planner/features/schedule/model/day_plan_item_model.dart';

class ActivityScreen extends ConsumerStatefulWidget {
  final String tripId;
  final DateTime date;
  final int dayNumber;

  const ActivityScreen({
    super.key,
    required this.tripId,
    required this.date,
    required this.dayNumber,
  });

  @override
  ConsumerState<ActivityScreen> createState() => _DayPlanDetailScreenState();
}

class _DayPlanDetailScreenState extends ConsumerState<ActivityScreen> {
  late final ActivityController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ActivityController(
      ref: ref,
      tripId: widget.tripId,
      date: widget.date,
    );
  }

  @override
  Widget build(BuildContext context) {
    final params = DayPlanParams(
      tripId: widget.tripId,
      date: widget.date,
    );
    final dayPlanAsync = ref.watch(watchDayPlanProvider(params));

    return Scaffold(
      appBar: _buildAppBar(),
      body: dayPlanAsync.when(
        data: (dayPlan) => dayPlan.items.isEmpty
            ? ActivityItemsEmptyState(
                onAddActivity: () => _controller.addNewItem(context),
              )
            : _buildDayPlanContent(dayPlan),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Błąd: $e')),
      ),
      floatingActionButton: GradientFAB(
        onPressed: () => _controller.addNewItem(context),
        icon: const Icon(Icons.add),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final dateFormat = DateFormat('EEEE, d MMMM yyyy', 'pl_PL');
    final formattedDate = dateFormat.format(widget.date);

    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dzień ${widget.dayNumber}'),
          Text(formattedDate, style: const TextStyle(fontSize: 12)),
        ],
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
      ),
    );
  }

  Widget _buildDayPlanContent(dynamic dayPlan) {
    final List<DayPlanItem> allItems = dayPlan.sortedItems;

    final List<DayPlanItem> scheduledItems =
        allItems.where((item) => !item.isChecklistItem).toList();
    final List<DayPlanItem> checklistItems =
        allItems.where((item) => item.isChecklistItem).toList();

    return Column(
      children: [
        if (scheduledItems.isNotEmpty)
          ActivityItemsListHeader(scheduledItems: scheduledItems),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (scheduledItems.isNotEmpty)
                  ActivityItemsList(
                    items: scheduledItems,
                    tripId: widget.tripId,
                    onTap: (item) => _controller.editItem(context, item),
                    onDelete: (item) => _controller.deleteItem(context, item),
                  ),
                if (checklistItems.isNotEmpty) ...[
                  if (scheduledItems.isNotEmpty) const SizedBox(height: 24),
                  ChecklistItemsSection(
                    items: checklistItems,
                    tripId: widget.tripId,
                    date: widget.date,
                    onEdit: (item) => _controller.editItem(context, item),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
