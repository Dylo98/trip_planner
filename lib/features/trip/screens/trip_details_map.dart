import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'package:trip_planner/features/trip/controller/watch_trip_provider.dart';
import 'package:trip_planner/features/trip/services/direction_service.dart';
import 'package:trip_planner/features/trip/widgets/marker_details_sheet.dart';
import 'package:trip_planner/features/trip/widgets/search_location.dart';

import 'package:trip_planner/features/trip/utils/handle_place_selected.dart';
import 'package:trip_planner/features/trip/utils/generate_polylines.dart';

class TripDetailsMapScreen extends ConsumerStatefulWidget {
  const TripDetailsMapScreen({super.key, required this.tripId});

  final String tripId;

  @override
  ConsumerState<TripDetailsMapScreen> createState() =>
      _TripDetailsMapScreenState();
}

class _TripDetailsMapScreenState extends ConsumerState<TripDetailsMapScreen> {
  late final ProviderSubscription _tripListener;
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  bool _hasDrawnPolylines = false;
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();

    _tripListener = ref.listenManual(
      watchTripProvider(widget.tripId),
      (previous, next) {
        if (next is AsyncData) {
          final trip = next.value;
          final newPolylines =
              DirectionService.drawPolylines(trip.markerPoints);
          setState(() {
            _polylines = newPolylines.toSet();
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _tripListener.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tripAsync = ref.watch(watchTripProvider(widget.tripId));

    return tripAsync.when(
      data: (trip) {
        final markers = trip.markerPoints;

        if (!_hasDrawnPolylines) {
          final newPolylines = generatePolylines(markers);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _polylines = newPolylines;
              _hasDrawnPolylines = true;
            });
          });
        }

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
                    onTap: () async {
                      await showMaterialModalBottomSheet(
                        context: context,
                        builder: (context) => SingleChildScrollView(
                          controller: ModalScrollController.of(context),
                          child: MarkerDetailsSheet(
                            marker: marker,
                            tripId: widget.tripId,
                          ),
                        ),
                      );
                    },
                  ),
              },
              polylines: _polylines,
              onMapCreated: (controller) {
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
                  await handlePlaceSelected(
                    context: context,
                    ref: ref,
                    tripId: widget.tripId,
                    position: position,
                    name: name,
                    controller: controller,
                    updatePolylines: (newPolylines) {
                      setState(() {
                        _polylines = newPolylines;
                      });
                    },
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
