import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:trip_planner/features/trip/services/current_location.dart';
import 'package:trip_planner/features/trip/model/marker_point_model.dart';
import 'package:trip_planner/features/trip/controller/trip_markers_provider.dart';
import 'package:trip_planner/features/trip/widgets/search_location.dart';

class NewTripMapScreen extends ConsumerStatefulWidget {
  const NewTripMapScreen({super.key});

  @override
  ConsumerState<NewTripMapScreen> createState() => _NewTripMapScreenState();
}

class _NewTripMapScreenState extends ConsumerState<NewTripMapScreen> {
  GoogleMapController? _mapController;

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(52.2297, 21.0122),
    zoom: 6,
  );

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _onMyLocationPressed() async {
    if (!mounted) return;

    final position = await CurrentLocation.getCurrentPosition(context: context);
    if (position == null || !mounted) return;

    final latLng = LatLng(position.latitude, position.longitude);

    ref.read(tripMarkersProvider.notifier).addMarker(
          MarkerPoint(
            id: 'currentLocation_${DateTime.now().millisecondsSinceEpoch}',
            position: latLng,
            name: 'Twoja lokalizacja',
          ),
        );

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(latLng, 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    final markerPoints = ref.watch(tripMarkersProvider);

    final markers = markerPoints.map((markerPoint) {
      return Marker(
        markerId: MarkerId(markerPoint.id),
        position: markerPoint.position,
        infoWindow: InfoWindow(title: markerPoint.name),
      );
    }).toSet();

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            markers: markers,
            initialCameraPosition: _initialPosition,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: SearchLocation(
              onPlaceSelected: (LatLng position, String name) {
                ref.read(tripMarkersProvider.notifier).addMarker(
                      MarkerPoint(
                        id: name,
                        position: position,
                        name: name,
                      ),
                    );
                _mapController?.animateCamera(
                  CameraUpdate.newLatLngZoom(position, 15),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onMyLocationPressed,
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
