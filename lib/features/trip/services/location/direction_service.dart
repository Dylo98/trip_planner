import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trip_planner/features/trip/model/marker_point_model.dart';

class DirectionService {
  static List<Polyline> drawPolylines(List<MarkerPoint> markerPoints) {
    if (markerPoints.length < 2) return [];

    final List<Polyline> polylines = [];

    for (int i = 0; i < markerPoints.length - 1; i++) {
      final start = markerPoints[i];
      final end = markerPoints[i + 1];

      Color color;
      List<PatternItem> pattern;

      switch (start.transportMode) {
        case 'plane':
          color = Colors.blue;
          pattern = [PatternItem.dash(20), PatternItem.gap(10)];
          break;
        case 'walk':
          color = Colors.green;
          pattern = [PatternItem.dot, PatternItem.gap(5)];
          break;
        case 'car':
          color = Colors.purple;
          pattern = [];
          break;
        case 'other':
        default:
          color = Colors.orange;
          pattern = [PatternItem.dash(10), PatternItem.gap(5)];
      }

      polylines.add(
        Polyline(
          polylineId: PolylineId('route_$i'),
          points: [start.position, end.position],
          color: color,
          width: 5,
          patterns: pattern,
        ),
      );
    }

    return polylines;
  }
}
