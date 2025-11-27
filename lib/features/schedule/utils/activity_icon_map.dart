import 'package:flutter/material.dart';

class ActivityIconMap {
  ActivityIconMap._();

  static const Map<String, IconData> _iconMap = {
    'restaurant': Icons.restaurant,
    'hotel': Icons.hotel,
    'local_cafe': Icons.local_cafe,
    'shopping': Icons.shopping_bag,
    'event': Icons.event,
    'attractions': Icons.attractions,
    'local_activity': Icons.local_activity,
    'roller_coaster': Icons.attractions_outlined,
  };

  static const List<ActivityIconOption> availableIcons = [
    ActivityIconOption(
      icon: Icons.restaurant,
      id: 'restaurant',
      label: 'Jedzenie',
    ),
    ActivityIconOption(
      icon: Icons.local_cafe,
      id: 'local_cafe',
      label: 'Kawa',
    ),
    ActivityIconOption(
      icon: Icons.hotel,
      id: 'hotel',
      label: 'Hotel',
    ),
    ActivityIconOption(
      icon: Icons.shopping_bag,
      id: 'shopping',
      label: 'Zakupy',
    ),
    ActivityIconOption(
      icon: Icons.event,
      id: 'event',
      label: 'Wydarzenie',
    ),
  ];

  static const List<ActivityIconOption> checklistIcons = [
    ActivityIconOption(
      icon: Icons.check_circle_outline,
      id: null,
      label: 'Domyślna',
    ),
    ActivityIconOption(
      icon: Icons.attractions_outlined,
      id: 'roller_coaster',
      label: 'Atrakcja',
    ),
    ActivityIconOption(
      icon: Icons.local_activity,
      id: 'local_activity',
      label: 'Aktywność',
    ),
    ActivityIconOption(
      icon: Icons.restaurant,
      id: 'restaurant',
      label: 'Restauracja',
    ),
    ActivityIconOption(
      icon: Icons.hotel,
      id: 'hotel',
      label: 'Hotel',
    ),
    ActivityIconOption(
      icon: Icons.attractions,
      id: 'attractions',
      label: 'Zabytki',
    ),
  ];

  static IconData getIcon(
    String? iconId, {
    IconData defaultIcon = Icons.event,
  }) {
    if (iconId == null) return defaultIcon;
    return _iconMap[iconId] ?? defaultIcon;
  }

  static IconData getChecklistIcon(String? iconId) {
    return getIcon(iconId, defaultIcon: Icons.check_circle_outline);
  }
}

class ActivityIconOption {
  final IconData icon;
  final String? id;
  final String label;

  const ActivityIconOption({
    required this.icon,
    required this.id,
    required this.label,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityIconOption &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
