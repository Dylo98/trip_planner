import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trip_planner/features/trip/model/marker_point_model.dart';
import 'package:trip_planner/features/trip/services/direction_service.dart';

Set<Polyline> generatePolylines(List<MarkerPoint> markers) {
  final newPolylines = DirectionService.drawPolylines(markers);
  return newPolylines.toSet();
}
