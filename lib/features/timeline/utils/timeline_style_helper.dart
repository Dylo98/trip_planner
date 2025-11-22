import 'package:flutter/material.dart';

class TimelineStyleHelper {
  final int index;
  final Color color;

  TimelineStyleHelper({required this.index}) : color = _getGradientColor(index);

  static const List<Color> _colors = [
    Colors.purple,
    Colors.pink,
    Colors.blue,
    Colors.orange,
    Colors.teal,
    Colors.indigo,
    Colors.deepOrange,
    Colors.cyan,
  ];

  static Color _getGradientColor(int index) {
    return _colors[index % _colors.length];
  }

  Color getLineColor() => color;

  Color getNextLineColor() => _getGradientColor(index + 1);

  BoxDecoration getIndicatorDecoration() {
    return BoxDecoration(
      shape: BoxShape.circle,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          color,
          color.withValues(alpha: 0.7),
        ],
      ),
      border: Border.all(
        color: Colors.white,
        width: 4,
      ),
      boxShadow: [
        BoxShadow(
          color: color.withValues(alpha: 0.4),
          blurRadius: 12,
          spreadRadius: 2,
        ),
      ],
    );
  }

  BoxDecoration getGradientDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          color,
          color.withValues(alpha: 0.7),
        ],
      ),
    );
  }

  BoxDecoration getCardDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white,
          color.withValues(alpha: 0.05),
        ],
      ),
      border: Border.all(
        color: color.withValues(alpha: 0.2),
        width: 2,
      ),
    );
  }

  BoxDecoration getBadgeDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          color,
          color.withValues(alpha: 0.7),
        ],
      ),
      borderRadius: BorderRadius.circular(20),
    );
  }

  static IconData getTransportIcon(String? mode) {
    if (mode == null) return Icons.location_on;

    switch (mode.toLowerCase()) {
      case 'car':
        return Icons.directions_car;
      case 'bus':
        return Icons.directions_bus;
      case 'train':
        return Icons.train;
      case 'plane':
        return Icons.flight;
      case 'walk':
        return Icons.directions_walk;
      case 'bike':
        return Icons.directions_bike;
      case 'boat':
        return Icons.directions_boat;
      default:
        return Icons.location_on;
    }
  }

  static String getCleanPlaceName(String? fullName) {
    if (fullName == null || fullName.isEmpty) return 'Bez nazwy';

    if (fullName.contains(',')) {
      return fullName.split(',').first.trim();
    }

    return fullName;
  }
}
