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
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  bool _hasInitializedPolylines = false;
  bool _isAddingCurrentLocation = false;

  bool _isLoadingMarkers = false;
  bool _useCustomMarkers = true;

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

  Future<void> _loadMarkers(markers) async {
    if (_isLoadingMarkers) return;

    setState(() => _isLoadingMarkers = true);

    try {
      final customMarkers = await _mapController.createMapMarkersAsync(
        markers,
        useCustomMarkers: _useCustomMarkers,
      );

      if (mounted) {
        setState(() {
          _markers = customMarkers;
          _isLoadingMarkers = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading custom markers: $e');
      if (mounted) {
        setState(() {
          _markers = _mapController.createMapMarkers(markers);
          _isLoadingMarkers = false;
        });
      }
    }
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

  void _toggleCustomMarkers() {
    setState(() {
      _useCustomMarkers = !_useCustomMarkers;
    });

    final tripAsync = ref.read(watchTripProvider(widget.tripId));
    tripAsync.whenData((trip) {
      _loadMarkers(trip.markerPoints);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tripAsync = ref.watch(watchTripProvider(widget.tripId));

    return tripAsync.when(
      data: (trip) {
        final markers = trip.markerPoints;

        if (_markers.isEmpty && markers.isNotEmpty && !_isLoadingMarkers) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _loadMarkers(markers);
          });
        }

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

        return Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: markers.isNotEmpty
                    ? markers.first.position
                    : const LatLng(52.2297, 21.0122),
                zoom: 5,
              ),
              markers: _markers,
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
            if (_isLoadingMarkers)
              Positioned(
                bottom: 80,
                left: 0,
                right: 0,
                child: Center(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 12),
                          Text('Ładowanie zdjęć markerów...'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            Positioned(
              top: 80,
              right: 16,
              child: SafeArea(
                child: FloatingActionButton.small(
                  heroTag: 'toggle_custom_markers',
                  onPressed: _toggleCustomMarkers,
                  tooltip: _useCustomMarkers
                      ? 'Wyłącz zdjęcia markerów'
                      : 'Włącz zdjęcia markerów',
                  backgroundColor: Colors.white,
                  child: Icon(
                    _useCustomMarkers ? Icons.image : Icons.pin_drop,
                    color: _useCustomMarkers ? Colors.blue : Colors.grey,
                  ),
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
