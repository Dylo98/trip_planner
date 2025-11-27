import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/core/widgets/app_notifications.dart';
import 'package:trip_planner/features/schedule/controller/day_plan_provider.dart';
import 'package:trip_planner/features/schedule/model/day_plan_item_model.dart';
import 'package:trip_planner/features/schedule/widgets/dialog/add_checklist_item_dialog.dart';
import 'package:trip_planner/features/schedule/widgets/dialog/add_day_plan_item_dialog.dart';

class ActivityController {
  final WidgetRef ref;
  final String tripId;
  final DateTime date;

  ActivityController({
    required this.ref,
    required this.tripId,
    required this.date,
  });

  Future<void> addNewItem(BuildContext context) async {
    if (!context.mounted) return;

    final type = await _showActivityTypeDialog(context);
    if (type == null || !context.mounted) return;

    final result = await _showItemDialog(context, type: type);
    if (result == null || !context.mounted) return;

    await _saveItem(context, result);
  }

  Future<void> editItem(BuildContext context, DayPlanItem item) async {
    if (!context.mounted) return;

    final result = await _showItemDialog(
      context,
      type: item.isChecklistItem ? 'checklist' : 'scheduled',
      editItem: item,
    );

    if (result == null || !context.mounted) return;

    await _updateItem(context, result);
  }

  Future<void> deleteItem(BuildContext context, DayPlanItem item) async {
    if (!context.mounted) return;

    final confirmed = await _showDeleteConfirmation(context, item.title);
    if (confirmed != true || !context.mounted) return;

    await _removeItem(context, item.id);
  }

  Future<String?> _showActivityTypeDialog(BuildContext context) async {
    return await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dodaj aktywność'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.schedule, color: Colors.blue),
              title: const Text('Aktywność z przedziałem czasowym'),
              onTap: () => Navigator.pop(context, 'scheduled'),
            ),
            ListTile(
              leading: const Icon(
                Icons.check_circle_outline,
                color: Colors.purple,
              ),
              title: const Text('Aktywność bez konkretnej godziny'),
              onTap: () => Navigator.pop(context, 'checklist'),
            ),
          ],
        ),
      ),
    );
  }

  Future<DayPlanItem?> _showItemDialog(
    BuildContext context, {
    required String type,
    DayPlanItem? editItem,
  }) async {
    if (type == 'checklist') {
      return await showDialog<DayPlanItem>(
        context: context,
        builder: (context) => AddChecklistItemDialog(
          date: date,
          editItem: editItem,
        ),
      );
    } else {
      return await showDialog<DayPlanItem>(
        context: context,
        builder: (context) => AddDayPlanItemDialog(
          tripId: tripId,
          date: date,
          editItem: editItem,
        ),
      );
    }
  }

  Future<void> _saveItem(BuildContext context, DayPlanItem item) async {
    try {
      final service = ref.read(dayPlanServiceProvider);
      await service.addItemToDayPlan(tripId, date, item);

      if (context.mounted) {
        AppNotifications.showSuccess(
          context: context,
          message: 'Dodano aktywność',
        );
      }
    } catch (e) {
      if (context.mounted) {
        AppNotifications.showError(
          context: context,
          message: 'Błąd podczas dodawania: $e',
        );
      }
    }
  }

  Future<void> _updateItem(BuildContext context, DayPlanItem item) async {
    try {
      final service = ref.read(dayPlanServiceProvider);
      await service.updateItemInDayPlan(tripId, date, item);

      if (context.mounted) {
        AppNotifications.showSuccess(
          context: context,
          message: 'Zaktualizowano aktywność',
        );
      }
    } catch (e) {
      if (context.mounted) {
        AppNotifications.showError(
          context: context,
          message: 'Błąd podczas aktualizacji: $e',
        );
      }
    }
  }

  Future<void> _removeItem(BuildContext context, String itemId) async {
    try {
      final service = ref.read(dayPlanServiceProvider);
      await service.removeItemFromDayPlan(tripId, date, itemId);

      if (context.mounted) {
        AppNotifications.showSuccess(
          context: context,
          message: 'Usunięto aktywność',
        );
      }
    } catch (e) {
      if (context.mounted) {
        AppNotifications.showError(
          context: context,
          message: 'Błąd podczas usuwania: $e',
        );
      }
    }
  }

  Future<bool?> _showDeleteConfirmation(
    BuildContext context,
    String title,
  ) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Usuń aktywność'),
        content: Text('Czy na pewno chcesz usunąć "$title"?'),
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
