import 'package:flutter/material.dart';

class TransportHelper {
  static String getName(String? mode) {
    return switch (mode) {
      'plane' => 'Samolot',
      'walk' => 'Pieszo',
      'car' => 'Samochód',
      _ => 'Inne',
    };
  }

  static IconData getIcon(String? mode) {
    return switch (mode) {
      'plane' => Icons.flight,
      'walk' => Icons.directions_walk,
      'car' => Icons.directions_car,
      _ => Icons.directions_bus,
    };
  }

  static Color getColor(String? mode) {
    return switch (mode) {
      'plane' => Colors.blue,
      'walk' => Colors.green,
      'car' => Colors.orange,
      _ => Colors.grey,
    };
  }

  static const List<String> allModes = ['plane', 'walk', 'car', 'other'];
}
