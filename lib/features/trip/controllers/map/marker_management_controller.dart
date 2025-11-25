import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trip_planner/core/utils/action_lock.dart';
import 'package:trip_planner/features/trip/model/marker_point_model.dart';
import 'package:trip_planner/features/trip/providers/trip_markers_provider.dart';
import 'package:trip_planner/features/trip/services/location/current_location.dart';
import 'package:trip_planner/features/trip/services/trip_service.dart';
import 'package:trip_planner/features/trip/utils/transport_helper.dart';
import 'marker_details_controller.dart';

class MarkerManagementController {
  MarkerManagementController({
    required this.ref,
    required this.detailsController,
  });

  final WidgetRef ref;
  final MarkerDetailsController detailsController;

  final ActionLock _placeLock = ActionLock();
  final ActionLock _myLocLock = ActionLock();

  bool get isPlaceLocked => _placeLock.isBusy;
  bool get isMyLocationLocked => _myLocLock.isBusy;

  Future<void> handleAddMarker({
    required BuildContext context,
    required LatLng position,
    required String name,
    String? tripId,
  }) async {
    return _placeLock.run(() async {
      final markers = ref.read(tripMarkersProvider);

      if (markers.isEmpty) {
        await _addFirstMarker(context, position, name, tripId: tripId);
      } else {
        await _addSubsequentMarker(context, position, name, tripId: tripId);
      }
    });
  }

  Future<void> handleAddMarkerToTrip({
    required BuildContext context,
    required String tripId,
    required LatLng position,
    required String name,
  }) async {
    return _placeLock.run(() async {
      final transportMode = await TransportHelper.selectTransport(context);
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
        transportMode: 'other',
      );

      await tripService.addMarkerToTrip(tripId, newMarker);

      await Future.delayed(const Duration(milliseconds: 300));
    });
  }

  Future<void> handleMyLocation({
    required BuildContext context,
    String? tripId,
  }) async {
    return _myLocLock.run(() async {
      if (!context.mounted) return;

      final position =
          await CurrentLocation.getCurrentPosition(context: context);
      if (position == null || !context.mounted) return;

      final latLng = LatLng(position.latitude, position.longitude);
      final markers = ref.read(tripMarkersProvider);

      final uniqueId =
          'currentLocation_${DateTime.now().millisecondsSinceEpoch}';

      if (markers.isEmpty) {
        await _addFirstMarker(
          context,
          latLng,
          'Twoja lokalizacja',
          id: uniqueId,
          tripId: tripId,
        );
      } else {
        await _addSubsequentMarker(
          context,
          latLng,
          'Twoja lokalizacja',
          id: uniqueId,
          tripId: tripId,
        );
      }
    });
  }

  Future<void> _addFirstMarker(
    BuildContext context,
    LatLng position,
    String name, {
    String? id,
    String? tripId,
  }) async {
    final newMarker = MarkerPoint(
      id: id ?? name,
      position: position,
      name: name,
      transportMode: 'other',
    );

    ref.read(tripMarkersProvider.notifier).addMarker(newMarker);

    if (context.mounted) {
      await detailsController.showMarkerDetails(
        context,
        newMarker,
        tripId: tripId,
      );
    }
  }

  Future<void> _addSubsequentMarker(
    BuildContext context,
    LatLng position,
    String name, {
    String? id,
    String? tripId,
  }) async {
    final transportMode = await TransportHelper.selectTransport(context);
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

    if (context.mounted) {
      await detailsController.showMarkerDetails(
        context,
        newMarker,
        tripId: tripId,
      );
    }
  }
}
