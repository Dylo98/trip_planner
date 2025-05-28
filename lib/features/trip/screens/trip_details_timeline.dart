import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:trip_planner/features/trip/controller/watch_trip_provider.dart';

class TripDetailsTimelineScreen extends ConsumerWidget {
  final String tripId;

  const TripDetailsTimelineScreen({super.key, required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripAsync = ref.watch(watchTripProvider(tripId));

    return Scaffold(
      body: tripAsync.when(
        data: (trip) {
          final markers = trip.markerPoints;

          if (markers.isEmpty) {
            return const Center(child: Text('Brak punktów na osi czasu'));
          }

          return ListView.builder(
            itemCount: markers.length,
            itemBuilder: (context, index) {
              final marker = markers[index];
              return TimelineTile(
                alignment: TimelineAlign.manual,
                lineXY: 0.1,
                isFirst: index == 0,
                isLast: index == markers.length - 1,
                beforeLineStyle:
                    const LineStyle(color: Colors.black, thickness: 2),
                afterLineStyle:
                    const LineStyle(color: Colors.black, thickness: 2),
                indicatorStyle: IndicatorStyle(
                  width: 20,
                  color: Colors.blue,
                  iconStyle: IconStyle(
                      iconData: Icons.location_on, color: Colors.white),
                ),
                endChild: ListTile(
                  title: Text(marker.name ?? 'Bez nazwy'),
                  subtitle: marker.description != null
                      ? Text(marker.description!)
                      : null,
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Błąd: $e')),
      ),
    );
  }
}
