import 'package:trip_planner/features/schedule/model/day_plan_item_model.dart';

class DayPlan {
  final DateTime date;
  final List<DayPlanItem> items;
  final String? notes;

  DayPlan({
    required this.date,
    required this.items,
    this.notes,
  });

  DateTime get dateOnly => DateTime(date.year, date.month, date.day);

  String get dateKey {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  List<DayPlanItem> get sortedItems {
    final sorted = List<DayPlanItem>.from(items);
    sorted.sort((a, b) => a.startTime.compareTo(b.startTime));
    return sorted;
  }

  int get totalDurationMinutes {
    return items.fold(0, (sum, item) => sum + item.durationMinutes);
  }

  bool get hasActivities => items.isNotEmpty;
  int get activityCount => items.length;

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      'notes': notes,
    };
  }

  factory DayPlan.fromJson(Map<String, dynamic> json) {
    return DayPlan(
      date: DateTime.parse(json['date'] as String),
      items: (json['items'] as List?)
              ?.map(
                  (item) => DayPlanItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      notes: json['notes'] as String?,
    );
  }

  DayPlan copyWith({
    DateTime? date,
    List<DayPlanItem>? items,
    String? notes,
  }) {
    return DayPlan(
      date: date ?? this.date,
      items: items ?? this.items,
      notes: notes ?? this.notes,
    );
  }

  factory DayPlan.empty(DateTime date) {
    return DayPlan(
      date: DateTime(date.year, date.month, date.day),
      items: [],
    );
  }
}
