import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/core/theme/text_style.dart';
import 'package:trip_planner/features/trip/controller/watch_trip_provider.dart';
import 'package:trip_planner/features/trip/model/trip_model.dart';
import 'package:trip_planner/features/trip/widgets/trip_details/trip_date_range.dart';
import 'package:trip_planner/features/trip/widgets/trip_details/trip_header_image.dart';
import 'package:trip_planner/features/trip/widgets/trip_details/trip_photo_grid.dart';

class TripDetailsScreen extends ConsumerWidget {
  const TripDetailsScreen({super.key, required this.trip});

  final Trip trip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripAsync = ref.watch(watchTripProvider(trip.id));

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            TripHeaderImage(imageUrl: trip.tripPhotoUrl),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(trip.name, style: AppTextStyles.heading1),
                  const SizedBox(height: 8),
                  TripDateRange(
                    startDate: trip.startDate,
                    endDate: trip.endDate,
                  ),
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: tripAsync.when(
                data: (liveTrip) {
                  final allImages = liveTrip.markerPoints
                      .expand((marker) => marker.imageUrl ?? <String>[])
                      .cast<String>()
                      .toList();

                  return TripPhotoGrid(imageUrls: allImages);
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text('Błąd: $e'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
