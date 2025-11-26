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
          color.withValues(alpha: 0.8),
        ],
      ),
      border: Border.all(
        color: Colors.white,
        width: 5,
      ),
      boxShadow: [
        BoxShadow(
          color: color.withValues(alpha: 0.5),
          blurRadius: 16,
          spreadRadius: 2,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 8,
          spreadRadius: 0,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  BoxDecoration getGradientDecoration() {
    return BoxDecoration(
      shape: BoxShape.circle,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          color,
          color.withValues(alpha: 0.8),
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
          color.withValues(alpha: 0.03),
        ],
      ),
      border: Border.all(
        color: color.withValues(alpha: 0.25),
        width: 2,
      ),
      boxShadow: [
        BoxShadow(
          color: color.withValues(alpha: 0.15),
          blurRadius: 12,
          spreadRadius: 0,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  BoxDecoration getBadgeDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          color,
          color.withValues(alpha: 0.85),
        ],
      ),
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: color.withValues(alpha: 0.3),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
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
      case 'other':
        return Icons.more_horiz;
      default:
        return Icons.location_on;
    }
  }

  static String getCleanPlaceName(String? fullName) {
    if (fullName == null || fullName.isEmpty) return 'Bez nazwy';

    String cleaned = fullName.trim();

    final commaIndex = cleaned.indexOf(',');
    final dashIndex = cleaned.indexOf('-');

    if (commaIndex != -1 && dashIndex != -1) {
      final firstSeparator = commaIndex < dashIndex ? commaIndex : dashIndex;
      return cleaned.substring(0, firstSeparator).trim();
    }

    if (commaIndex != -1) {
      return cleaned.substring(0, commaIndex).trim();
    }

    if (dashIndex != -1) {
      return cleaned.substring(0, dashIndex).trim();
    }
    return cleaned;
  }

  static String getTransportModeName(String? mode) {
    if (mode == null) return 'Brak';

    switch (mode.toLowerCase()) {
      case 'car':
        return 'Samochód';
      case 'bus':
        return 'Autobus';
      case 'train':
        return 'Pociąg';
      case 'plane':
        return 'Samolot';
      case 'walk':
        return 'Pieszo';
      case 'bike':
        return 'Rower';
      case 'boat':
        return 'Łódź';
      case 'other':
        return 'Inne';
      default:
        return 'Nieznany';
    }
  }
}
