import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/core/theme/text_style.dart';
import 'package:trip_planner/features/trip/providers/watch_trip_provider.dart';
import 'package:trip_planner/features/trip/model/trip_model.dart';
import 'package:trip_planner/features/trip/controllers/trip_details_edit_controller.dart';
import 'package:trip_planner/features/trip/widgets/trip_details/trip_date_range.dart';
import 'package:trip_planner/features/trip/widgets/trip_details/trip_header_image.dart';
import 'package:trip_planner/features/trip/widgets/trip_details/trip_photo_grid.dart';
import 'package:trip_planner/features/trip/widgets/trip_details/trip_status_chip.dart';

class TripDetailsScreen extends ConsumerWidget {
  const TripDetailsScreen({super.key, required this.trip});

  final Trip trip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripAsync = ref.watch(watchTripProvider(trip.id));

    final editController = TripDetailsEditController(
      ref: ref,
      context: context,
      trip: trip,
    );

    return Scaffold(
      body: tripAsync.when(
        data: (liveTrip) => _buildContent(context, liveTrip, editController),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Błąd: $e'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    Trip liveTrip,
    TripDetailsEditController editController,
  ) {
    final allImages = liveTrip.markerPoints
        .expand((marker) => marker.imageUrl ?? <String>[])
        .cast<String>()
        .toList();

    return SingleChildScrollView(
      child: Column(
        children: [
          TripHeaderImage(
            imageUrl: liveTrip.tripPhotoUrl,
            isEditable: true,
            onEditPressed: () async {
              await editController.handlePhotoChange();
            },
            onRemovePressed: liveTrip.tripPhotoUrl != null
                ? () async {
                    await editController.handlePhotoRemoval();
                  }
                : null,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                InkWell(
                  onTap: () async {
                    await editController.handleNameChange();
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            liveTrip.name,
                            style: AppTextStyles.heading1,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TripStatusChip(trip: liveTrip),
                const SizedBox(height: 16),
                TripDateRange(
                  startDate: liveTrip.startDate,
                  endDate: liveTrip.endDate,
                  isEditable: true,
                  onEditPressed: () async {
                    await editController.handleDateChange();
                  },
                ),
                if (liveTrip.description?.isNotEmpty == true) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      liveTrip.description!,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                if (allImages.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.photo_library_outlined,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Brak zdjęć z podróży',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  TripPhotoGrid(imageUrls: allImages),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
