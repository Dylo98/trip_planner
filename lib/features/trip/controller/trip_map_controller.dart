import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:trip_planner/core/utils/action_lock.dart';
import 'package:trip_planner/core/utils/debouncer.dart';
import 'package:trip_planner/features/trip/controller/trip_markers_provider.dart';
import 'package:trip_planner/features/trip/model/marker_point_model.dart';
import 'package:trip_planner/features/trip/services/current_location.dart';
import 'package:trip_planner/features/trip/services/direction_service.dart';
import 'package:trip_planner/features/trip/services/trip_service.dart';
import 'package:trip_planner/features/trip/widgets/marker_details_sheet/marker_details_sheet.dart';
import 'package:trip_planner/features/trip/widgets/select_transport.dart';

class TripMapController {
  TripMapController({
    required this.ref,
    required this.context,
    this.tripId,
  });

  final WidgetRef ref;
  final BuildContext context;
  final String? tripId;

  GoogleMapController? _mapController;

  final ActionLock _placeLock = ActionLock();
  final ActionLock _myLocLock = ActionLock();
  final ActionLock _sheetLock = ActionLock();
  final Debouncer _polyDebouncer = Debouncer(milliseconds: 250);

  bool get isPlaceLocked => _placeLock.isBusy;
  bool get isMyLocationLocked => _myLocLock.isBusy;
  bool get isSheetLocked => _sheetLock.isBusy;

  void setMapController(GoogleMapController controller) {
    _mapController = controller;
  }

  void dispose() {
    _mapController?.dispose();
    _polyDebouncer.dispose();
  }

  Set<Polyline> generatePolylines(List<MarkerPoint> markers) {
    if (markers.length < 2) return {};
    return DirectionService.drawPolylines(markers).toSet();
  }

  Future<void> animateToPosition(LatLng position, {double zoom = 15}) async {
    await _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(position, zoom),
    );
  }

  Future<void> handleAddMarker({
    required LatLng position,
    required String name,
  }) async {
    return _placeLock.run(() async {
      final markers = ref.read(tripMarkersProvider);

      if (markers.isEmpty) {
        await _addFirstMarker(position, name);
      } else {
        await _addSubsequentMarker(position, name);
      }

      await animateToPosition(position);
    });
  }

  Future<void> handleAddMarkerToTrip({
    required String tripId,
    required LatLng position,
    required String name,
    required Function(Set<Polyline>) onPolylinesUpdate,
  }) async {
    return _placeLock.run(() async {
      final transportMode = await selectTransport(context);
      if (transportMode == null) return;

      final tripService = ref.read(tripServiceProvider);

      final tripSnapshot = await tripService.getTrip(tripId);
      if (tripSnapshot != null && tripSnapshot.markerPoints.isNotEmpty) {
        final lastMarker = tripSnapshot.markerPoints.last;
        await tripService.updateMarkerTransportMode(
          tripId: tripId,
          markerId: lastMarker.id,
          transportMode: transportMode,
        );
      }

      final newMarker = MarkerPoint(
        id: name,
        name: name,
        position: position,
      );

      await tripService.addMarkerToTrip(tripId, newMarker);
      await animateToPosition(position);

      final updatedTrip = await tripService.getTrip(tripId);
      if (updatedTrip != null) {
        onPolylinesUpdate(generatePolylines(updatedTrip.markerPoints));
      }
    });
  }

  Future<void> handleMyLocation() async {
    return _myLocLock.run(() async {
      if (!context.mounted) return;

      final position =
          await CurrentLocation.getCurrentPosition(context: context);
      if (position == null || !context.mounted) return;

      final latLng = LatLng(position.latitude, position.longitude);
      final markers = ref.read(tripMarkersProvider);

      if (markers.isEmpty) {
        await _addFirstMarker(
          latLng,
          'Twoja lokalizacja',
          id: 'currentLocation_${DateTime.now().millisecondsSinceEpoch}',
        );
      } else {
        await _addSubsequentMarker(
          latLng,
          'Twoja lokalizacja',
          id: 'currentLocation_${DateTime.now().millisecondsSinceEpoch}',
        );
      }

      await animateToPosition(latLng, zoom: 14);
    });
  }

  Future<void> showMarkerDetails(MarkerPoint marker) async {
    await _sheetLock.run(() async {
      if (!context.mounted) return;
      await showMaterialModalBottomSheet(
        context: context,
        builder: (_) => MarkerDetailsSheet(
          marker: marker,
          tripId: tripId,
        ),
      );
    });
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
        onTap: () async {
          if (onMarkerTap != null) {
            onMarkerTap(markerPoint);
          } else {
            await showMarkerDetails(markerPoint);
          }
        },
      );
    }).toSet();
  }

  Future<void> _addFirstMarker(
    LatLng position,
    String name, {
    String? id,
  }) async {
    final newMarker = MarkerPoint(
      id: id ?? name,
      position: position,
      name: name,
      transportMode: 'other',
    );

    ref.read(tripMarkersProvider.notifier).addMarker(newMarker);

    await _sheetLock.run(() async {
      if (!context.mounted) return;
      await showMaterialModalBottomSheet(
        context: context,
        builder: (_) => MarkerDetailsSheet(
          marker: newMarker,
          tripId: tripId,
        ),
      );
    });
  }

  Future<void> _addSubsequentMarker(
    LatLng position,
    String name, {
    String? id,
  }) async {
    final transportMode = await selectTransport(context);
    if (transportMode == null) return;

    final markers = ref.read(tripMarkersProvider);
    final lastMarker = markers.last;

    ref
        .read(tripMarkersProvider.notifier)
        .updateMarkerTransport(lastMarker.id, transportMode);

    final newMarker = MarkerPoint(
      id: id ?? name,
      position: position,
      name: name,
      transportMode: 'other',
    );

    ref.read(tripMarkersProvider.notifier).addMarker(newMarker);

    await _sheetLock.run(() async {
      if (!context.mounted) return;
      await showMaterialModalBottomSheet(
        context: context,
        builder: (_) => MarkerDetailsSheet(
          marker: newMarker,
          tripId: tripId,
        ),
      );
    });
  }
}
