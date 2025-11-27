import 'package:flutter/material.dart';
import 'package:trip_planner/features/schedule/model/day_plan_item_model.dart';
import 'package:trip_planner/features/trip/model/marker_point_model.dart';
import 'package:trip_planner/features/budget/model/expense_item_model.dart';
import 'package:uuid/uuid.dart';

class ActivityDialogController {
  final String tripId;
  final DateTime date;
  final DayPlanItem? editItem;

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay? endTime;
  String? selectedIcon;
  MarkerPoint? selectedLocationMarker;
  MarkerPoint? selectedMarker;
  List<ExpenseItem> expenses = [];

  ActivityDialogController({
    required this.tripId,
    required this.date,
    this.editItem,
  }) {
    _initializeFromEditItem();
  }

  bool get isEditing => editItem != null;
  int get initialTabIndex => (editItem?.type == DayPlanItemType.marker) ? 1 : 0;

  void _initializeFromEditItem() {
    if (editItem == null) return;

    titleController.text = editItem!.title;
    descriptionController.text = editItem!.description ?? '';
    startTime = TimeOfDay.fromDateTime(editItem!.startTime);

    if (editItem!.endTime != null) {
      endTime = TimeOfDay.fromDateTime(editItem!.endTime!);
    }

    selectedIcon = editItem!.icon;
    expenses = editItem!.expenses ?? [];
  }

  void updateStartTime(TimeOfDay time) {
    startTime = time;
  }

  void updateEndTime(TimeOfDay? time) {
    endTime = time;
  }

  void clearEndTime() {
    endTime = null;
  }

  void selectIcon(String? icon) {
    selectedIcon = icon;
  }

  void selectLocationMarker(MarkerPoint? marker) {
    selectedLocationMarker = marker;
  }

  void selectMarker(MarkerPoint? marker) {
    selectedMarker = marker;
    if (marker != null) {
      titleController.text = marker.name ?? '';
      descriptionController.text = marker.description ?? '';
    }
  }

  void updateExpenses(List<ExpenseItem> newExpenses) {
    expenses = newExpenses;
  }

  DayPlanItem? buildCustomItem() {
    if (titleController.text.trim().isEmpty) {
      return null;
    }

    final startDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      startTime.hour,
      startTime.minute,
    );

    final endDateTime = endTime != null
        ? DateTime(
            date.year,
            date.month,
            date.day,
            endTime!.hour,
            endTime!.minute,
          )
        : null;

    return DayPlanItem(
      id: editItem?.id ?? const Uuid().v4(),
      type: DayPlanItemType.custom,
      startTime: startDateTime,
      endTime: endDateTime,
      title: titleController.text.trim(),
      description: descriptionController.text.trim().isEmpty
          ? null
          : descriptionController.text.trim(),
      icon: selectedIcon,
      markerId: selectedLocationMarker?.id,
      location: selectedLocationMarker?.position,
      order: editItem?.order ?? 0,
      expenses: expenses,
    );
  }

  DayPlanItem? buildMarkerItem() {
    if (selectedMarker == null) {
      return null;
    }

    final startDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      startTime.hour,
      startTime.minute,
    );

    final endDateTime = endTime != null
        ? DateTime(
            date.year,
            date.month,
            date.day,
            endTime!.hour,
            endTime!.minute,
          )
        : null;

    return DayPlanItem(
      id: editItem?.id ?? const Uuid().v4(),
      type: DayPlanItemType.marker,
      startTime: startDateTime,
      endTime: endDateTime,
      title: selectedMarker!.name ?? 'Bez nazwy',
      description: selectedMarker!.description,
      markerId: selectedMarker!.id,
      location: selectedMarker!.position,
      icon: selectedIcon,
      order: editItem?.order ?? 0,
      expenses: expenses,
    );
  }

  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
  }
}
