import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trip_planner/features/trip/model/marker_point_model.dart';
import 'package:trip_planner/features/trip/providers/trip_markers_provider.dart';
import 'package:trip_planner/features/trip/services/trip_service.dart';
import 'map_camera_controller.dart';
import 'marker_details_controller.dart';
import 'marker_display_controller.dart';
import 'marker_management_controller.dart';
import 'polyline_controller.dart';

/// Główny kontroler mapy
class TripMapController {
  TripMapController({
    required this.ref,
    required this.context,
    this.tripId,
  })  : cameraController = MapCameraController(),
        polylineController = PolylineController(),
        markerDisplayController = MarkerDisplayController(),
        detailsController = MarkerDetailsController() {
    markerManagementController = MarkerManagementController(
      ref: ref,
      detailsController: detailsController,
    );
  }

  final WidgetRef ref;
  final BuildContext context;
  final String? tripId;

  final MapCameraController cameraController;
  final PolylineController polylineController;
  final MarkerDisplayController markerDisplayController;
  final MarkerDetailsController detailsController;
  late final MarkerManagementController markerManagementController;

  void setMapController(GoogleMapController controller) {
    cameraController.setMapController(controller);
  }

  Future<void> animateToPosition(LatLng position, {double zoom = 15}) async {
    await cameraController.animateToPosition(position, zoom: zoom);
  }

  Future<void> animateToBounds(LatLngBounds bounds) async {
    await cameraController.animateToBounds(bounds);
  }

  Set<Polyline> generatePolylines(List<MarkerPoint> markers) {
    return polylineController.generatePolylines(markers);
  }

  Set<Marker> createMapMarkers(
    List<MarkerPoint> markerPoints, {
    Function(MarkerPoint)? onMarkerTap,
  }) {
    return markerDisplayController.createMapMarkers(
      markerPoints,
      onMarkerTap: onMarkerTap ?? (marker) => showMarkerDetails(marker),
    );
  }

  Future<void> showMarkerDetails(MarkerPoint marker) async {
    await detailsController.showMarkerDetails(context, marker, tripId: tripId);
  }

  Future<void> handleAddMarker({
    required LatLng position,
    required String name,
  }) async {
    await markerManagementController.handleAddMarker(
      context: context,
      position: position,
      name: name,
      tripId: tripId,
    );
    await animateToPosition(position);
  }

  Future<void> handleAddMarkerToTrip({
    required String tripId,
    required LatLng position,
    required String name,
    required Function(Set<Polyline>) onPolylinesUpdate,
  }) async {
    await markerManagementController.handleAddMarkerToTrip(
      context: context,
      tripId: tripId,
      position: position,
      name: name,
    );
    await animateToPosition(position);

    final tripService = ref.read(tripServiceProvider);
    final updatedTrip = await tripService.getTrip(tripId);
    if (updatedTrip != null) {
      onPolylinesUpdate(generatePolylines(updatedTrip.markerPoints));
    }
  }

  Future<void> handleMyLocation() async {
    await markerManagementController.handleMyLocation(
      context: context,
      tripId: tripId,
    );

    final markers = ref.read(tripMarkersProvider);
    if (markers.isNotEmpty) {
      await animateToPosition(markers.last.position, zoom: 14);
    }
  }

  bool get isPlaceLocked => markerManagementController.isPlaceLocked;
  bool get isMyLocationLocked => markerManagementController.isMyLocationLocked;
  bool get isSheetLocked => detailsController.isSheetLocked;

  void dispose() {
    cameraController.dispose();
  }
}
