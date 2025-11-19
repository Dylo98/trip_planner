import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trip_planner/features/statistics/model/traveler_statistics.dart';

class WorldHeatmap extends StatefulWidget {
  final TravelerStatistics statistics;

  const WorldHeatmap({
    super.key,
    required this.statistics,
  });

  @override
  State<WorldHeatmap> createState() => _WorldHeatmapState();
}

class _WorldHeatmapState extends State<WorldHeatmap> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _createMarkers();
  }

  void _createMarkers() {
    for (final entry in widget.statistics.citiesByCountry.entries) {
      for (final city in entry.value) {
        _markers.add(
          Marker(
            markerId: MarkerId('${city.cityName}_${city.latitude}'),
            position: LatLng(city.latitude, city.longitude),
            infoWindow: InfoWindow(
              title: city.cityName,
              snippet: entry.key,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: const CameraPosition(
        target: LatLng(50.0, 10.0),
        zoom: 4,
      ),
      markers: _markers,
      onMapCreated: (controller) {
        _mapController = controller;
      },
      mapType: MapType.normal,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: true,
      zoomGesturesEnabled: true,
      scrollGesturesEnabled: true,
      tiltGesturesEnabled: true,
      rotateGesturesEnabled: true,
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
