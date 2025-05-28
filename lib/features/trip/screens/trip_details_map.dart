import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:trip_planner/features/trip/controller/watch_trip_provider.dart';
import 'package:trip_planner/features/trip/model/marker_point_model.dart';
import 'package:trip_planner/features/trip/services/direction_service.dart';
import 'package:trip_planner/features/trip/services/trip_service.dart';
import 'package:trip_planner/features/trip/widgets/marker_details_sheet.dart';
import 'package:trip_planner/features/trip/widgets/search_location.dart';

class TripDetailsMapScreen extends ConsumerStatefulWidget {
  const TripDetailsMapScreen({super.key, required this.tripId});

  final String tripId;

  @override
  ConsumerState<TripDetailsMapScreen> createState() =>
      _TripDetailsMapScreenState();
}

class _TripDetailsMapScreenState extends ConsumerState<TripDetailsMapScreen> {
  Set<Polyline> _polylines = {};
  late GoogleMapController _mapController;

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  Future<void> _drawPolylines(List<MarkerPoint> markerPoints) async {
    final newPolylines = await DirectionService.drawRouteBetweenMarkers(
      markerPoints,
      dotenv.env['GOOGLE_PLACES_API_KEY']!,
    );

    setState(() {
      _polylines = {..._polylines, ...newPolylines};
    });
  }

  @override
  Widget build(BuildContext context) {
    final tripAsync = ref.watch(watchTripProvider(widget.tripId));

    return tripAsync.when(
      data: (trip) {
        final markers = trip.markerPoints;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _drawPolylines(markers);
        });

        return Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: markers.isNotEmpty
                    ? markers.first.position
                    : const LatLng(52.2297, 21.0122),
                zoom: 5,
              ),
              markers: {
                for (final marker in markers)
                  Marker(
                    markerId: MarkerId(marker.id),
                    position: marker.position,
                    infoWindow: InfoWindow(title: marker.name),
                    onTap: () {
                      showMaterialModalBottomSheet(
                        context: context,
                        builder: (context) => SingleChildScrollView(
                          controller: ModalScrollController.of(context),
                          child: MarkerDetailsSheet(
                              marker: marker, tripId: widget.tripId),
                        ),
                      );
                    },
                  ),
              },
              polylines: _polylines,
              onMapCreated: (controller) {
                _mapController = controller;
                if (!_controller.isCompleted) {
                  _controller.complete(controller);
                }
              },
            ),
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: SearchLocation(
                onPlaceSelected: (LatLng position, String name) async {
                  final controller = await _controller.future;

                  final newMarker = MarkerPoint(
                    id: name,
                    name: name,
                    position: position,
                  );

                  await ref.read(tripServiceProvider).addMarkerToTrip(
                        widget.tripId,
                        newMarker,
                      );

                  controller.animateCamera(
                    CameraUpdate.newLatLngZoom(position, 15),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Błąd: $err')),
    );
  }
}
