import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/features/trip/model/marker_point_model.dart';
import 'package:trip_planner/features/trip/providers/trip_markers_provider.dart';
import 'package:trip_planner/features/trip/services/google_places/google_places_models.dart';
import 'package:trip_planner/features/trip/services/trip_service.dart';
import 'package:trip_planner/features/trip/utils/transport_helper.dart';

class GooglePlaceAdditionController {
  final WidgetRef ref;
  final BuildContext context;
  final String? tripId;

  GooglePlaceAdditionController({
    required this.ref,
    required this.context,
    required this.tripId,
  });

  bool get isNewTrip => tripId == null;

  Future<void> handlePlaceSelection(GooglePlace place) async {
    if (!context.mounted) return;

    final transport = await TransportHelper.selectTransport(context);
    if (transport == null || !context.mounted) return;

    final newMarker = _createMarkerFromPlace(place, transport);

    await _addMarkerToTrip(newMarker, transport);

    if (context.mounted) {
      _showSuccessMessage(place.name, transport);
    }
  }

  MarkerPoint _createMarkerFromPlace(GooglePlace place, String transport) {
    return MarkerPoint(
      id: place.placeId,
      position: place.location,
      name: place.name,
      description: place.vicinity,
      transportMode: 'other',
      imageUrl: null,
      expenses: null,
    );
  }

  Future<void> _addMarkerToTrip(MarkerPoint marker, String transport) async {
    if (isNewTrip) {
      final markers = ref.read(tripMarkersProvider);

      if (markers.isNotEmpty) {
        ref.read(tripMarkersProvider.notifier).updateMarkerTransport(
              markers.last.id,
              transport,
            );
      }

      ref.read(tripMarkersProvider.notifier).addMarker(marker);
    } else {
      final tripService = ref.read(tripServiceProvider);

      final tripSnapshot = await tripService.getTrip(tripId!);
      if (tripSnapshot != null && tripSnapshot.markerPoints.isNotEmpty) {
        final lastMarker = tripSnapshot.markerPoints.last;
        await tripService.updateMarkerTransportMode(
          tripId: tripId!,
          markerId: lastMarker.id,
          transportMode: transport,
        );
      }

      await tripService.addMarkerToTrip(tripId!, marker);

      if (context.mounted) {
        Navigator.pop(context);
      }
    }
  }

  void _showSuccessMessage(String placeName, String transport) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Dodano: $placeName (${TransportHelper.getName(transport)})',
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
