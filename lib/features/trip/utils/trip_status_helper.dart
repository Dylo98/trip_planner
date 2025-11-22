import 'package:flutter/material.dart';
import 'package:trip_planner/features/trip/model/trip_model.dart';

class TripStatusHelper {
  final TripStatus status;

  const TripStatusHelper(this.status);

  Color get color {
    return switch (status) {
      TripStatus.upcoming => Colors.blue,
      TripStatus.ongoing => Colors.green,
      TripStatus.completed => Colors.grey,
    };
  }

  IconData get icon {
    return switch (status) {
      TripStatus.upcoming => Icons.schedule,
      TripStatus.ongoing => Icons.flight_takeoff,
      TripStatus.completed => Icons.check_circle,
    };
  }

  String get label {
    return switch (status) {
      TripStatus.upcoming => 'Przyszła',
      TripStatus.ongoing => 'Trwa',
      TripStatus.completed => 'Zakończona',
    };
  }

  static Color colorFor(TripStatus status) => TripStatusHelper(status).color;

  static IconData iconFor(TripStatus status) => TripStatusHelper(status).icon;

  static String labelFor(TripStatus status) => TripStatusHelper(status).label;
}
