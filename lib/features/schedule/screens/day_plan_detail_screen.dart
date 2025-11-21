import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:trip_planner/features/schedule/controller/day_plan_provider.dart';
import 'package:trip_planner/features/schedule/model/day_plan_item_model.dart';
import 'package:trip_planner/features/schedule/widgets/day_plan/add_day_plan_item_dialog.dart';
import 'package:trip_planner/features/schedule/widgets/day_plan/day_plan_item_card.dart';

class DayPlanDetailScreen extends ConsumerStatefulWidget {
  final String tripId;
  final DateTime date;
  final int dayNumber;

  const DayPlanDetailScreen({
    super.key,
    required this.tripId,
    required this.date,
    required this.dayNumber,
  });

  @override
  ConsumerState<DayPlanDetailScreen> createState() =>
      _DayPlanDetailScreenState();
}

class _DayPlanDetailScreenState extends ConsumerState<DayPlanDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final params = DayPlanParams(
      tripId: widget.tripId,
      date: widget.date,
    );
    final dayPlanAsync = ref.watch(watchDayPlanProvider(params));

    final dateFormat = DateFormat('EEEE, d MMMM yyyy', 'pl_PL');
    final formattedDate = dateFormat.format(widget.date);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dzień ${widget.dayNumber}'),
            Text(
              formattedDate,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfo(context),
            tooltip: 'Informacje',
          ),
        ],
      ),
      body: dayPlanAsync.when(
        data: (dayPlan) {
          if (dayPlan.items.isEmpty) {
            return _buildEmptyState();
          }

          return _buildDayPlanContent(dayPlan);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Błąd: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewItem,
        icon: const Icon(Icons.add),
        label: const Text('Dodaj'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.schedule_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              'Brak zaplanowanych aktywności',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Dodaj pierwszą aktywność do swojego planu dnia',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _addNewItem,
              icon: const Icon(Icons.add),
              label: const Text('Dodaj aktywność'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayPlanContent(dynamic dayPlan) {
    final items = (dayPlan.sortedItems as List).cast<DayPlanItem>();

    return Column(
      children: [
        _buildTimelineHeader(items),
        Expanded(
          child: ReorderableListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            onReorder: (oldIndex, newIndex) {
              _onReorder(items, oldIndex, newIndex);
            },
            itemBuilder: (context, index) {
              final item = items[index];
              return DayPlanItemCard(
                key: ValueKey(item.id),
                item: item,
                tripId: widget.tripId,
                onTap: () => _editItem(item),
                onDelete: () => _deleteItem(item),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineHeader(List<DayPlanItem> items) {
    if (items.isEmpty) return const SizedBox.shrink();

    final firstTime = items.first.startTime;
    final lastTime = items.last.endTime ?? items.last.startTime;
    final duration = lastTime.difference(firstTime);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.access_time, color: Colors.blue.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Harmonogram dnia',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
                Text(
                  '${_formatTime(firstTime)} - ${_formatTime(lastTime)} (${_formatDuration(duration)})',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.shade700,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${items.length} ${items.length == 1 ? "aktywność" : "aktywności"}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addNewItem() async {
    final result = await showDialog<DayPlanItem>(
      context: context,
      builder: (context) => AddDayPlanItemDialog(
        tripId: widget.tripId,
        date: widget.date,
      ),
    );

    if (result != null) {
      final service = ref.read(dayPlanServiceProvider);
      await service.addItemToDayPlan(widget.tripId, widget.date, result);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dodano aktywność'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _editItem(DayPlanItem item) async {
    final result = await showDialog<DayPlanItem>(
      context: context,
      builder: (context) => AddDayPlanItemDialog(
        tripId: widget.tripId,
        date: widget.date,
        editItem: item,
      ),
    );

    if (result != null) {
      final service = ref.read(dayPlanServiceProvider);
      await service.updateItemInDayPlan(widget.tripId, widget.date, result);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Zaktualizowano aktywność'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _deleteItem(DayPlanItem item) async {
    final confirmed = await showDialog<bool>(
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

    if (confirmed == true) {
      final service = ref.read(dayPlanServiceProvider);
      await service.removeItemFromDayPlan(widget.tripId, widget.date, item.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usunięto aktywność'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _onReorder(
    List<DayPlanItem> items,
    int oldIndex,
    int newIndex,
  ) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final reorderedItems = List<DayPlanItem>.from(items);
    final item = reorderedItems.removeAt(oldIndex);
    reorderedItems.insert(newIndex, item);

    final service = ref.read(dayPlanServiceProvider);
    await service.reorderDayPlanItems(
        widget.tripId, widget.date, reorderedItems);
  }

  void _showInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Jak używać planu dnia'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '• Dodaj aktywności za pomocą przycisku +\n'
                '• Wybierz marker z podróży lub stwórz własną aktywność\n'
                '• Przeciągnij aktywności, aby zmienić kolejność\n'
                '• Kliknij aktywność, aby ją edytować\n'
                '• Przesuń w lewo, aby usunąć',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Rozumiem'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}min';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}min';
    }
  }
}
