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

  @override
  void didUpdateWidget(WorldHeatmap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.statistics != widget.statistics) {
      _createMarkers();
    }
  }

  void _createMarkers() {
    _markers.clear();

    for (final entry in widget.statistics.placesByCountry.entries) {
      final country = entry.key;
      final places = entry.value;

      for (final place in places) {
        _markers.add(
          Marker(
            markerId: MarkerId(
                '${place.placeName}_${place.latitude}_${place.longitude}'),
            position: LatLng(place.latitude, place.longitude),
            infoWindow: InfoWindow(
              title: place.placeName,
              snippet: country,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            ),
          ),
        );
      }
    }

    for (final entry in widget.statistics.citiesByCountry.entries) {
      final country = entry.key;
      final cities = entry.value;

      for (final city in cities) {
        _markers.add(
          Marker(
            markerId: MarkerId(
                'city_${city.cityName}_${city.latitude}_${city.longitude}'),
            position: LatLng(city.latitude, city.longitude),
            infoWindow: InfoWindow(
              title: city.cityName,
              snippet: '$country (miasto)',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueBlue,
            ),
          ),
        );
      }
    }

    if (mounted) {
      setState(() {});
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
      compassEnabled: true,
      mapToolbarEnabled: true,
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
