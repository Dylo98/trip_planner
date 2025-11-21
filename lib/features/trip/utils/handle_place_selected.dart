import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/features/trip/providers/watch_trip_provider.dart';
import 'package:trip_planner/features/trip/model/marker_point_model.dart';
import 'package:trip_planner/features/trip/services/trip_service.dart';
import 'package:trip_planner/features/trip/widgets/select_transport.dart';
import 'package:trip_planner/features/trip/services/direction_service.dart';

Future<void> handlePlaceSelected({
  required BuildContext context,
  required WidgetRef ref,
  required String tripId,
  required LatLng position,
  required String name,
  required GoogleMapController controller,
  required void Function(Set<Polyline>) updatePolylines,
}) async {
  final transport = await selectTransport(context);
  if (transport == null) return;

  final trip = ref.read(watchTripProvider(tripId)).asData?.value;
  final previousMarkers = trip?.markerPoints ?? [];

  if (previousMarkers.isNotEmpty) {
    final lastMarker = previousMarkers.last.copyWith(
      transportMode: transport,
    );

    await ref.read(tripServiceProvider).updateMarkerTransportMode(
          tripId: tripId,
          markerId: lastMarker.id,
          transportMode: transport,
        );
  }

  final newMarker = MarkerPoint(
    id: name,
    name: name,
    position: position,
  );

  await ref.read(tripServiceProvider).addMarkerToTrip(tripId, newMarker);

  controller.animateCamera(CameraUpdate.newLatLngZoom(position, 15));

  final updatedTrip = ref.read(watchTripProvider(tripId)).asData?.value;
  final newPolylines = DirectionService.drawPolylines(
    updatedTrip?.markerPoints ?? [],
  );

  updatePolylines(newPolylines.toSet());
}
