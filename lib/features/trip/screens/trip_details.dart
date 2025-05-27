import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:trip_planner/features/trip/controller/watch_trip_provider.dart';
import 'package:trip_planner/features/trip/model/trip_model.dart';

class TripDetailsScreen extends ConsumerStatefulWidget {
  const TripDetailsScreen({super.key, required this.trip});

  final Trip trip;

  @override
  ConsumerState<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends ConsumerState<TripDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final tripAsync = ref.watch(watchTripProvider(widget.trip.id));
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.trip.name),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              widget.trip.tripPhotoUrl != null &&
                      Uri.tryParse(widget.trip.tripPhotoUrl!)
                              ?.hasAbsolutePath ==
                          true
                  ? Image.network(
                      widget.trip.tripPhotoUrl!,
                    )
                  : Container(
                      width: double.infinity,
                      height: 200,
                      color: Colors.grey[300],
                      alignment: Alignment.center,
                      child: const Text(
                        'Brak zdjęcia',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text('Nazwa: ${widget.trip.name}'),
                    Text(
                      'Data: ${DateFormat('dd-MM-yyyy').format(widget.trip.startDate!)}',
                    ),
                  ],
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: tripAsync.when(
                  data: (liveTrip) {
                    final markers = liveTrip.markerPoints;
                    if (markers.isEmpty) {
                      return const Center(child: Text('Brak markerów'));
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: markers.length,
                      itemBuilder: (context, index) {
                        final marker = markers[index];
                        return TimelineTile(
                          alignment: TimelineAlign.manual,
                          lineXY: 0.1,
                          isFirst: index == 0,
                          isLast: index == markers.length - 1,
                          beforeLineStyle: const LineStyle(
                              color: Colors.black, thickness: 2),
                          afterLineStyle: const LineStyle(
                              color: Colors.black, thickness: 2),
                          indicatorStyle: IndicatorStyle(
                            width: 20,
                            color: Colors.blue,
                            iconStyle: IconStyle(
                                iconData: Icons.location_on,
                                color: Colors.white),
                          ),
                          endChild: ListTile(
                            title: Text(marker.name!),
                          ),
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Błąd: $e')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
