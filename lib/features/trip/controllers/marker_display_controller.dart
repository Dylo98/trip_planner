import 'dart:ui';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trip_planner/features/trip/model/marker_point_model.dart';

/// Kontroler odpowiedzialny za tworzenie wizualnych markerów na mapie
class MarkerDisplayController {
  Set<Marker> createMapMarkers(
    List<MarkerPoint> markerPoints, {
    Function(MarkerPoint)? onMarkerTap,
  }) {
    return markerPoints.map((markerPoint) {
      return Marker(
        markerId: MarkerId(markerPoint.id),
        position: markerPoint.position,
        infoWindow: InfoWindow(title: markerPoint.name),
        onTap: onMarkerTap != null ? () => onMarkerTap(markerPoint) : null,
      );
    }).toSet();
  }

  Set<Marker> createSingleMarker(
    MarkerPoint markerPoint, {
    VoidCallback? onTap,
  }) {
    return {
      Marker(
        markerId: MarkerId(markerPoint.id),
        position: markerPoint.position,
        infoWindow: InfoWindow(title: markerPoint.name),
        onTap: onTap,
      ),
    };
  }
}
