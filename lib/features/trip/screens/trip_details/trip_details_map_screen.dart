import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trip_planner/features/trip/providers/watch_trip_provider.dart';
import 'package:trip_planner/features/trip/controllers/map/trip_map_controller.dart';
import 'package:trip_planner/features/trip/widgets/shared/search_location.dart';
import 'package:trip_planner/features/trip/services/location/current_location.dart';
import 'package:trip_planner/core/widgets/loading_indicator.dart';
import 'package:trip_planner/core/widgets/error_display.dart';
import 'package:trip_planner/features/trip/widgets/shared/map_location_fab.dart';

class TripDetailsMapScreen extends ConsumerStatefulWidget {
  const TripDetailsMapScreen({super.key, required this.tripId});

  final String tripId;

  @override
  ConsumerState<TripDetailsMapScreen> createState() =>
      _TripDetailsMapScreenState();
}

class _TripDetailsMapScreenState extends ConsumerState<TripDetailsMapScreen> {
  late final TripMapController _mapController;
  Set<Polyline> _polylines = {};
  bool _hasInitializedPolylines = false;
  bool _isAddingCurrentLocation = false;

  @override
  void initState() {
    super.initState();
    _mapController = TripMapController(
      ref: ref,
      context: context,
      tripId: widget.tripId,
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _updatePolylines(Set<Polyline> newPolylines) {
    if (mounted) {
      setState(() {
        _polylines = newPolylines;
      });
    }
  }

  Future<void> _handlePlaceSelected(LatLng position, String name) async {
    if (_mapController.isPlaceLocked) return;

    await _mapController.handleAddMarkerToTrip(
      tripId: widget.tripId,
      position: position,
      name: name,
      onPolylinesUpdate: _updatePolylines,
    );
  }

  Future<void> _addCurrentLocationMarker() async {
    if (_isAddingCurrentLocation) return;

    setState(() => _isAddingCurrentLocation = true);

    try {
      final position = await CurrentLocation.getCurrentPosition(
        context: context,
      );

      if (position == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nie udało się pobrać lokalizacji'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final latLng = LatLng(position.latitude, position.longitude);

      await _mapController.handleAddMarkerToTrip(
        tripId: widget.tripId,
        position: latLng,
        name: 'Moja lokalizacja',
        onPolylinesUpdate: _updatePolylines,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dodano punkt: Moja lokalizacja'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Błąd: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAddingCurrentLocation = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tripAsync = ref.watch(watchTripProvider(widget.tripId));

    return tripAsync.when(
      data: (trip) {
        final markers = trip.markerPoints;

        if (!_hasInitializedPolylines && markers.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _polylines = _mapController.generatePolylines(markers);
                _hasInitializedPolylines = true;
              });
            }
          });
        }

        final mapMarkers = _mapController.createMapMarkers(markers);

        return Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: markers.isNotEmpty
                    ? markers.first.position
                    : const LatLng(52.2297, 21.0122),
                zoom: 5,
              ),
              markers: mapMarkers,
              polylines: _polylines,
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
            Positioned(
              bottom: 16,
              left: 16,
              child: SafeArea(
                child: MapLocationFab(
                  onPressed: _addCurrentLocationMarker,
                  isLoading: _isAddingCurrentLocation,
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const LoadingIndicator(),
      error: (err, _) => ErrorDisplay(error: err),
    );
  }
}
