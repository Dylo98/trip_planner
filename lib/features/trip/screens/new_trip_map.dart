import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/* SERVICES */
import 'package:trip_planner/features/trip/services/current_location.dart';

/* MODEL */
import 'package:trip_planner/features/trip/model/marker_point_model.dart';

/* CONTROLLER */
import 'package:trip_planner/features/trip/controller/trip_markers_provider.dart';

/* WIDGETS */
import 'package:trip_planner/features/trip/widgets/search_location.dart';

class NewTripMapScreen extends ConsumerStatefulWidget {
  const NewTripMapScreen({super.key});

  @override
  ConsumerState<NewTripMapScreen> createState() => _NewTripMapScreenState();
}

class _NewTripMapScreenState extends ConsumerState<NewTripMapScreen> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(52.2297, 21.0122),
    zoom: 12,
  );

  @override
  Widget build(BuildContext context) {
    final markers = ref.watch(tripMarkersProvider.notifier).toGoogleMarkers();
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SearchLocation(
                onPlaceSelected: (LatLng position, String name) async {
                  final controller = await _controller.future;
                  ref.read(tripMarkersProvider.notifier).addMarker(
                        MarkerPoint(
                          id: name,
                          position: position,
                          name: name,
                        ),
                      );
                  controller.animateCamera(
                    CameraUpdate.newLatLngZoom(position, 15),
                  );
                },
              ),
              SizedBox(
                height: 400,
                child: GoogleMap(
                  mapType: MapType.normal,
                  markers: Set<Marker>.from(markers),
                  initialCameraPosition: _initialPosition,
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final position = await CurrentLocation.getCurrentPosition();
          final cameraPosition = CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 14,
          );
          ref.read(tripMarkersProvider.notifier).addMarker(
                MarkerPoint(
                  id: 'currentLocation',
                  position: LatLng(position.latitude, position.longitude),
                  name: 'Twoja lokalizacja',
                ),
              );
          final controller = await _controller.future;
          controller.animateCamera(
            CameraUpdate.newCameraPosition(cameraPosition),
          );
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
