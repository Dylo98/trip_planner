import 'package:google_maps_flutter/google_maps_flutter.dart';

enum DayPlanItemType {
  marker,
  custom,
}

class DayPlanItem {
  final String id;
  final DayPlanItemType type;
  final DateTime startTime;
  final DateTime? endTime;
  final String title;
  final String? description;
  final String? markerId;
  final LatLng? location;
  final String? icon;
  final String? color;
  final int order;

  DayPlanItem({
    required this.id,
    required this.type,
    required this.startTime,
    this.endTime,
    required this.title,
    this.description,
    this.markerId,
    this.location,
    this.icon,
    this.color,
    required this.order,
  });

  int get durationMinutes {
    if (endTime == null) return 60;
    return endTime!.difference(startTime).inMinutes;
  }

  bool get isMarkerLinked => type == DayPlanItemType.marker && markerId != null;

  String get timeRange {
    final start = _formatTime(startTime);
    if (endTime == null) return start;
    final end = _formatTime(endTime!);
    return '$start - $end';
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'title': title,
      'description': description,
      'markerId': markerId,
      'location': location != null
          ? {
              'latitude': location!.latitude,
              'longitude': location!.longitude,
            }
          : null,
      'icon': icon,
      'color': color,
      'order': order,
    };
  }

  factory DayPlanItem.fromJson(Map<String, dynamic> json) {
    LatLng? location;
    if (json['location'] != null) {
      final loc = json['location'] as Map<String, dynamic>;
      location = LatLng(
        (loc['latitude'] as num).toDouble(),
        (loc['longitude'] as num).toDouble(),
      );
    }

    return DayPlanItem(
      id: json['id'] as String,
      type: DayPlanItemType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => DayPlanItemType.custom,
      ),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      title: json['title'] as String,
      description: json['description'] as String?,
      markerId: json['markerId'] as String?,
      location: location,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      order: json['order'] as int? ?? 0,
    );
  }

  DayPlanItem copyWith({
    String? id,
    DayPlanItemType? type,
    DateTime? startTime,
    DateTime? endTime,
    String? title,
    String? description,
    String? markerId,
    LatLng? location,
    String? icon,
    String? color,
    int? order,
  }) {
    return DayPlanItem(
      id: id ?? this.id,
      type: type ?? this.type,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      title: title ?? this.title,
      description: description ?? this.description,
      markerId: markerId ?? this.markerId,
      location: location ?? this.location,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      order: order ?? this.order,
    );
  }
}
