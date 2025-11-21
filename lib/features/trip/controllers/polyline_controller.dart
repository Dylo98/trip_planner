import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trip_planner/features/trip/model/marker_point_model.dart';
import 'package:trip_planner/features/trip/services/direction_service.dart';

/// Kontroler odpowiedzialny za generowanie i zarządzanie trasami
class PolylineController {
  Set<Polyline> generatePolylines(List<MarkerPoint> markers) {
    if (markers.length < 2) return {};
    return DirectionService.drawPolylines(markers).toSet();
  }

  Set<Polyline> generatePolylinesForSegment(
    MarkerPoint start,
    MarkerPoint end,
  ) {
    return DirectionService.drawPolylines([start, end]).toSet();
  }
}
