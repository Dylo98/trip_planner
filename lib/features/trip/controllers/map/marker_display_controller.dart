import 'dart:ui';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trip_planner/features/trip/model/marker_point_model.dart';
import 'package:trip_planner/features/trip/services/marker/custom_marker_service.dart';

class MarkerDisplayController {
  Future<Set<Marker>> createMapMarkersAsync(
    List<MarkerPoint> markerPoints, {
    Function(MarkerPoint)? onMarkerTap,
    bool useCustomMarkers = true,
  }) async {
    if (!useCustomMarkers) {
      return createMapMarkers(markerPoints, onMarkerTap: onMarkerTap);
    }

    final Set<Marker> markers = {};

    for (final markerPoint in markerPoints) {
      BitmapDescriptor icon;

      if (markerPoint.imageUrl != null && markerPoint.imageUrl!.isNotEmpty) {
        try {
          icon = await CustomMarkerService.createMarkerWithImage(
            imageUrl: markerPoint.imageUrl!.first,
            size: 100,
          );
        } catch (e) {
          icon = BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueRed,
          );
        }
      } else {
        icon = BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueRed,
        );
      }

      markers.add(
        Marker(
          markerId: MarkerId(markerPoint.id),
          position: markerPoint.position,
          icon: icon,
          infoWindow: InfoWindow(title: markerPoint.name),
          onTap: onMarkerTap != null ? () => onMarkerTap(markerPoint) : null,
        ),
      );
    }

    return markers;
  }

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

  Future<Set<Marker>> createSingleMarkerAsync(
    MarkerPoint markerPoint, {
    VoidCallback? onTap,
    bool useCustomMarker = true,
  }) async {
    BitmapDescriptor icon;

    if (useCustomMarker &&
        markerPoint.imageUrl != null &&
        markerPoint.imageUrl!.isNotEmpty) {
      try {
        icon = await CustomMarkerService.createMarkerWithImage(
          imageUrl: markerPoint.imageUrl!.first,
          size: 100,
        );
      } catch (e) {
        icon = BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueRed,
        );
      }
    } else {
      icon = BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueRed,
      );
    }

    return {
      Marker(
        markerId: MarkerId(markerPoint.id),
        position: markerPoint.position,
        icon: icon,
        infoWindow: InfoWindow(title: markerPoint.name),
        onTap: onTap,
      ),
    };
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
