import 'dart:async';

import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

class NewTripScreen extends StatefulWidget {
  const NewTripScreen({super.key});

  @override
  State<NewTripScreen> createState() => _NewTripScreenState();
}

class _NewTripScreenState extends State<NewTripScreen> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(52.2297, 21.0122),
    zoom: 12,
  );

  final List<Marker> myMarker = [];
  final List<Marker> markerList = const [
    Marker(
      markerId: MarkerId('First'),
      position: LatLng(52.2297, 21.0122),
      infoWindow: InfoWindow(title: 'My Position'),
    ),
    Marker(
      markerId: MarkerId('Second'),
      position: LatLng(52.2503, 21.0122),
      infoWindow: InfoWindow(title: 'My Position 2'),
    ),
    Marker(
      markerId: MarkerId('Third'),
      position: LatLng(52.2503, 21.0622),
      infoWindow: InfoWindow(title: 'My Position 3'),
    ),
    Marker(
      markerId: MarkerId('Fourth'),
      position: LatLng(52.2903, 21.0622),
      infoWindow: InfoWindow(title: 'My Position 4'),
    ),
  ];

  @override
  void initState() {
    super.initState();
    myMarker.addAll(markerList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nowa podróż'),
      ),
      body: SafeArea(
        child: GoogleMap(
          mapType: MapType.normal,
          markers: Set<Marker>.of(myMarker),
          initialCameraPosition: _initialPosition,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final GoogleMapController controller = await _controller.future;
          controller.animateCamera(
            CameraUpdate.newCameraPosition(
              const CameraPosition(
                target: LatLng(52.2903, 21.0622),
                zoom: 12,
              ),
            ),
          );
          setState(() {});
        },
        child: Icon(Icons.add_location_alt_outlined),
      ),
    );
  }
}
