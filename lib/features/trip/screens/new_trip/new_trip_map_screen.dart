import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trip_planner/features/trip/providers/trip_form_provider.dart';
import 'package:trip_planner/features/trip/providers/trip_markers_provider.dart';
import 'package:trip_planner/features/trip/controllers/map/trip_map_controller.dart';
import 'package:trip_planner/features/trip/providers/trip_photo_provider.dart';
import 'package:trip_planner/features/trip/widgets/shared/map_location_fab.dart';
import 'package:trip_planner/features/trip/widgets/shared/search_location.dart';
import 'package:trip_planner/features/trip/services/location/current_location.dart';
import 'package:trip_planner/features/trip/widgets/shared/starting_location_dialog.dart';
import 'package:trip_planner/features/trip/widgets/shared/starting_location_banner.dart';

final hasStartingLocationProvider = StateProvider<bool>((ref) => false);
final isSelectingStartingLocationProvider = StateProvider<bool>((ref) => false);

class NewTripMapScreen extends ConsumerStatefulWidget {
  const NewTripMapScreen({super.key});

  @override
  ConsumerState<NewTripMapScreen> createState() => _NewTripMapScreenState();
}

class _NewTripMapScreenState extends ConsumerState<NewTripMapScreen> {
  late final TripMapController _mapController;
  Set<Polyline> _polylines = {};
  bool _isLoadingLocation = false;
  int _searchLocationKey = 0;

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final hasStarting = ref.read(hasStartingLocationProvider);
      if (!hasStarting) {
        _showStartingLocationDialog();
      }
    });
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

    final isSelectingStart = ref.read(isSelectingStartingLocationProvider);

    if (isSelectingStart) {
      await _mapController.handleAddMarker(position: position, name: name);
      ref.read(hasStartingLocationProvider.notifier).state = true;
      ref.read(isSelectingStartingLocationProvider.notifier).state = false;

      if (mounted) {
        setState(() {
          _searchLocationKey++;
        });
      }
    } else {
      await _mapController.handleAddMarker(position: position, name: name);

      if (mounted) {
        setState(() {
          _searchLocationKey++;
        });
      }
    }
  }

  Future<void> _handleMyLocation() async {
    if (_mapController.isMyLocationLocked) return;
    await _mapController.handleMyLocation();
  }

  Future<void> _showStartingLocationDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StartingLocationDialog(
        onUseCurrentLocation: _handleUseCurrentLocation,
        onSearchLocation: _handleSearchStartingLocation,
      ),
    );
  }

  Future<void> _handleUseCurrentLocation() async {
    Navigator.of(context).pop();

    setState(() => _isLoadingLocation = true);

    final position = await CurrentLocation.getCurrentPosition(context: context);

    if (position != null && mounted) {
      final latLng = LatLng(position.latitude, position.longitude);

      await _mapController.handleAddMarker(
        position: latLng,
        name: 'Punkt startowy',
      );

      await _mapController.animateToPosition(latLng, zoom: 14);

      ref.read(hasStartingLocationProvider.notifier).state = true;
    }

    if (mounted) {
      setState(() => _isLoadingLocation = false);
    }
  }

  void _handleSearchStartingLocation() {
    Navigator.of(context).pop();
    ref.read(isSelectingStartingLocationProvider.notifier).state = true;
  }

  void _handleBannerClose() {
    ref.read(isSelectingStartingLocationProvider.notifier).state = false;
    _showStartingLocationDialog();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<List<dynamic>>(tripMarkersProvider, (prev, next) {
      Future.microtask(_updatePolylines);

      if (next.isNotEmpty && !ref.read(hasStartingLocationProvider)) {
        ref.read(hasStartingLocationProvider.notifier).state = true;
      }
    });

    final markerPoints = ref.watch(tripMarkersProvider);
    final markers = _mapController.createMapMarkers(markerPoints);
    final isSelectingStart = ref.watch(isSelectingStartingLocationProvider);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          ref.invalidate(tripFormProvider);
          ref.invalidate(tripPhotoProvider);
          ref.read(tripMarkersProvider.notifier).clear();
          ref.read(hasStartingLocationProvider.notifier).state = false;
        }
      },
      child: Scaffold(
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
                child: Column(
                  children: [
                    if (isSelectingStart)
                      StartingLocationBanner(
                        onClose: _handleBannerClose,
                      ),
                    SearchLocation(
                      key: ValueKey(_searchLocationKey),
                      onPlaceSelected: _handlePlaceSelected,
                    ),
                  ],
                ),
              ),
            ),
            if (_isLoadingLocation)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        color: Colors.white,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Pobieranie lokalizacji...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        floatingActionButton: MapLocationFab(
          onPressed: _handleMyLocation,
          isLoading: _mapController.isMyLocationLocked,
        ),
      ),
    );
  }
}
