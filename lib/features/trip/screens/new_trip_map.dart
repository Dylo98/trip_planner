import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:trip_planner/features/trip/services/current_location.dart';
import 'package:trip_planner/features/trip/model/marker_point_model.dart';
import 'package:trip_planner/features/trip/controller/trip_markers_provider.dart';
import 'package:trip_planner/features/trip/widgets/search_location.dart';
import 'package:trip_planner/features/trip/widgets/select_transport.dart';
import 'package:trip_planner/features/trip/services/direction_service.dart';
import 'package:trip_planner/features/trip/widgets/marker_details_sheet/marker_details_sheet.dart';
import 'package:trip_planner/core/utils/action_lock.dart';
import 'package:trip_planner/core/utils/debouncer.dart';

class NewTripMapScreen extends ConsumerStatefulWidget {
  const NewTripMapScreen({super.key});

  @override
  ConsumerState<NewTripMapScreen> createState() => _NewTripMapScreenState();
}

class _NewTripMapScreenState extends ConsumerState<NewTripMapScreen> {
  GoogleMapController? _mapController;
  Set<Polyline> _polylines = {};

  final ActionLock _placeLock = ActionLock();
  final ActionLock _myLocLock = ActionLock();
  final ActionLock _sheetLock = ActionLock();

  final Debouncer _polyDebouncer = Debouncer(milliseconds: 250);

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(52.2297, 21.0122),
    zoom: 6,
  );

  @override
  void dispose() {
    _mapController?.dispose();
    _polyDebouncer.dispose();
    super.dispose();
  }

  void _updatePolylines() {
    final markerPoints = ref.read(tripMarkersProvider);
    if (markerPoints.length >= 2) {
      final newPolylines = DirectionService.drawPolylines(markerPoints);
      setState(() {
        _polylines = newPolylines.toSet();
      });
    } else {
      if (_polylines.isNotEmpty) {
        setState(() => _polylines = {});
      }
    }
  }

  Future<void> _handlePlaceSelected(LatLng position, String name) {
    return _placeLock.run(() async {
      final markerPoints = ref.read(tripMarkersProvider);

      if (markerPoints.isEmpty) {
        final newMarker = MarkerPoint(
          id: name,
          position: position,
          name: name,
          transportMode: 'other',
        );
        ref.read(tripMarkersProvider.notifier).addMarker(newMarker);

        await _sheetLock.run(() async {
          if (!mounted) return;
          await showMaterialModalBottomSheet(
            context: context,
            builder: (_) => MarkerDetailsSheet(
              marker: newMarker,
              tripId: null,
            ),
          );
        });
      } else {
        final transportMode = await selectTransport(context);
        if (transportMode == null) return;

        final lastMarker = markerPoints.last;
        ref
            .read(tripMarkersProvider.notifier)
            .updateMarkerTransport(lastMarker.id, transportMode);

        final newMarker = MarkerPoint(
          id: name,
          position: position,
          name: name,
          transportMode: 'other',
        );
        ref.read(tripMarkersProvider.notifier).addMarker(newMarker);

        await _sheetLock.run(() async {
          if (!mounted) return;
          await showMaterialModalBottomSheet(
            context: context,
            builder: (_) => MarkerDetailsSheet(
              marker: newMarker,
              tripId: null,
            ),
          );
        });
      }

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(position, 15),
      );
    });
  }

  Future<void> _onMyLocationPressed() {
    return _myLocLock.run(() async {
      if (!mounted) return;

      final position =
          await CurrentLocation.getCurrentPosition(context: context);
      if (position == null || !mounted) return;

      final latLng = LatLng(position.latitude, position.longitude);
      final markerPoints = ref.read(tripMarkersProvider);

      if (markerPoints.isEmpty) {
        final newMarker = MarkerPoint(
          id: 'currentLocation_${DateTime.now().millisecondsSinceEpoch}',
          position: latLng,
          name: 'Twoja lokalizacja',
          transportMode: 'other',
        );

        ref.read(tripMarkersProvider.notifier).addMarker(newMarker);

        await _sheetLock.run(() async {
          if (!mounted) return;
          await showMaterialModalBottomSheet(
            context: context,
            builder: (_) => MarkerDetailsSheet(
              marker: newMarker,
              tripId: null,
            ),
          );
        });
      } else {
        final transportMode = await selectTransport(context);
        if (transportMode == null) return;

        final lastMarker = markerPoints.last;
        ref
            .read(tripMarkersProvider.notifier)
            .updateMarkerTransport(lastMarker.id, transportMode);

        final newMarker = MarkerPoint(
          id: 'currentLocation_${DateTime.now().millisecondsSinceEpoch}',
          position: latLng,
          name: 'Twoja lokalizacja',
          transportMode: 'other',
        );

        ref.read(tripMarkersProvider.notifier).addMarker(newMarker);

        await _sheetLock.run(() async {
          if (!mounted) return;
          await showMaterialModalBottomSheet(
            context: context,
            builder: (_) => MarkerDetailsSheet(
              marker: newMarker,
              tripId: null,
            ),
          );
        });
      }

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(latLng, 14),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<List<MarkerPoint>>(tripMarkersProvider, (prev, next) {
      _polyDebouncer.run(_updatePolylines);
    });
    final markerPoints = ref.watch(tripMarkersProvider);

    final markers = markerPoints.map((markerPoint) {
      return Marker(
        markerId: MarkerId(markerPoint.id),
        position: markerPoint.position,
        infoWindow: InfoWindow(title: markerPoint.name),
        onTap: () async {
          await _sheetLock.run(() async {
            if (!mounted) return;
            await showMaterialModalBottomSheet(
              context: context,
              builder: (_) => MarkerDetailsSheet(
                marker: markerPoint,
                tripId: null,
              ),
            );
          });
        },
      );
    }).toSet();

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
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: SafeArea(
              child: SearchLocation(
                onPlaceSelected: (pos, name) {
                  if (_placeLock.isBusy || _sheetLock.isBusy) return;
                  unawaited(_handlePlaceSelected(pos, name));
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _myLocLock.isBusy ? null : _onMyLocationPressed,
        child: _myLocLock.isBusy
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.my_location),
      ),
    );
  }
}
