import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trip_planner/features/trip/controller/watch_trip_provider.dart';
import 'package:trip_planner/features/trip/model/marker_point_model.dart';
import 'package:trip_planner/features/trip/services/direction_service.dart';

class TripDetailsMapScreen extends ConsumerStatefulWidget {
  const TripDetailsMapScreen({super.key, required this.tripId});

  final String tripId;

  @override
  ConsumerState<TripDetailsMapScreen> createState() =>
      _TripDetailsMapScreenState();
}

class _TripDetailsMapScreenState extends ConsumerState<TripDetailsMapScreen> {
  Set<Polyline> _polylines = {};
  late GoogleMapController _mapController;

  Future<void> _drawPolyline(List<MarkerPoint> markerPoints) async {
    final newPolylines = await DirectionService.drawRouteBetweenMarkers(
      markerPoints,
      dotenv.env['GOOGLE_PLACES_API_KEY']!,
    );

    setState(() {
      _polylines = {..._polylines, ...newPolylines};
    });
  }

  @override
  Widget build(BuildContext context) {
    final tripAsync = ref.watch(watchTripProvider(widget.tripId));

    return tripAsync.when(
      data: (trip) {
        final markers = trip.markerPoints;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _drawPolyline(markers);
        });

        return GoogleMap(
          initialCameraPosition: CameraPosition(
            target: markers.isNotEmpty
                ? markers.first.position
                : const LatLng(52.2297, 21.0122),
            zoom: 5,
          ),
          markers: {
            for (final marker in markers)
              Marker(
                markerId: MarkerId(marker.id),
                position: marker.position,
                infoWindow: InfoWindow(title: marker.name),
              ),
          },
          polylines: _polylines,
          onMapCreated: (controller) => _mapController = controller,
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Błąd: $err')),
    );
  }
}
