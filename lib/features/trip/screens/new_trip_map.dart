import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trip_planner/features/trip/controller/trip_markers_provider.dart';
import 'package:trip_planner/features/trip/controller/trip_map_controller.dart';
import 'package:trip_planner/features/trip/widgets/map/map_location_fab.dart';
import 'package:trip_planner/features/trip/widgets/search_location.dart';

class NewTripMapScreen extends ConsumerStatefulWidget {
  const NewTripMapScreen({super.key});

  @override
  ConsumerState<NewTripMapScreen> createState() => _NewTripMapScreenState();
}

class _NewTripMapScreenState extends ConsumerState<NewTripMapScreen> {
  late final TripMapController _mapController;
  Set<Polyline> _polylines = {};

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(52.2297, 21.0122),
    zoom: 6,
  );

  @override
  void initState() {
    super.initState();
    _mapController = TripMapController(
      ref: ref,
      context: context,
      tripId: null,
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _updatePolylines() {
    final markerPoints = ref.read(tripMarkersProvider);
    setState(() {
      _polylines = _mapController.generatePolylines(markerPoints);
    });
  }

  Future<void> _handlePlaceSelected(LatLng position, String name) async {
    if (_mapController.isPlaceLocked || _mapController.isSheetLocked) return;
    await _mapController.handleAddMarker(position: position, name: name);
  }

  Future<void> _handleMyLocation() async {
    if (_mapController.isMyLocationLocked) return;
    await _mapController.handleMyLocation();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<List<dynamic>>(tripMarkersProvider, (prev, next) {
      Future.microtask(_updatePolylines);
    });

    final markerPoints = ref.watch(tripMarkersProvider);
    final markers = _mapController.createMapMarkers(markerPoints);

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            markers: markers,
            polylines: _polylines,
            initialCameraPosition: _initialPosition,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            onMapCreated: _mapController.setMapController,
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: SafeArea(
              child: SearchLocation(
                onPlaceSelected: _handlePlaceSelected,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: MapLocationFab(
        onPressed: _handleMyLocation,
        isLoading: _mapController.isMyLocationLocked,
      ),
    );
  }
}
