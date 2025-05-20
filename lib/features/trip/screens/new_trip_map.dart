import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trip_planner/features/trip/widgets/transform_latlng.dart';

class NewTripMapScreen extends StatefulWidget {
  const NewTripMapScreen({super.key});

  @override
  State<NewTripMapScreen> createState() => _NewTripMapScreenState();
}

class _NewTripMapScreenState extends State<NewTripMapScreen> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(52.2297, 21.0122),
    zoom: 12,
  );

  final List<Marker> myMarker = [];
  final List<Marker> markerList = const [];

  @override
  void initState() {
    super.initState();
    myMarker.addAll(markerList);
  }

  Future<Position> _getCurrentPosition() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Nie można uzyskać dostępu do lokalizacji. Sprawdź ustawienia lokalizacji.',
          ),
        ),
      );
    });
    return await Geolocator.getCurrentPosition();
  }

  packData() {
    _getCurrentPosition().then((value) async {
      CameraPosition cameraPosition = CameraPosition(
        target: LatLng(value.latitude, value.longitude),
        zoom: 14,
      );

      myMarker.add(
        Marker(
          markerId: const MarkerId('currentLocation'),
          position: LatLng(value.latitude, value.longitude),
          infoWindow: const InfoWindow(
            title: 'Twoja lokalizacja',
          ),
        ),
      );

      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(
        CameraUpdate.newCameraPosition(cameraPosition),
      );
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TransformLatlng(),
              SizedBox(
                height: 400,
                child: GoogleMap(
                  mapType: MapType.normal,
                  markers: Set<Marker>.of(myMarker),
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
        onPressed: () {
          packData();
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
