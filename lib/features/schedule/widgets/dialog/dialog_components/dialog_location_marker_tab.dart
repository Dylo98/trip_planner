import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/core/theme/colors.dart';
import 'package:trip_planner/core/theme/text_style.dart';
import 'package:trip_planner/features/trip/model/marker_point_model.dart';
import 'package:trip_planner/features/trip/providers/watch_trip_provider.dart';
import 'package:trip_planner/features/schedule/widgets/dialog/dialog_components/dialog_location_marker.dart';

class DialogLocationMarkerTab extends ConsumerWidget {
  final String tripId;
  final MarkerPoint? selectedMarker;
  final ValueChanged<MarkerPoint?> onMarkerSelected;

  const DialogLocationMarkerTab({
    super.key,
    required this.tripId,
    required this.selectedMarker,
    required this.onMarkerSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripAsync = ref.watch(watchTripProvider(tripId));

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
            border: Border(
              bottom: BorderSide(color: AppColors.borderPrimaryLight),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.place, color: AppColors.textPrimary),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Wybierz lokalizację',
                  style: AppTextStyles.heading3,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
        Expanded(
          child: tripAsync.when(
            data: (trip) {
              final markers = trip.markerPoints;

              if (markers.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      'Brak markerów w podróży.\nDodaj markery na mapie.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: markers.length,
                itemBuilder: (context, index) {
                  final marker = markers[index];
                  final isSelected = selectedMarker?.id == marker.id;

                  return DialogLocationMarker(
                    marker: marker,
                    isSelected: isSelected,
                    onTap: () => onMarkerSelected(
                      isSelected ? null : marker,
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Błąd: $e')),
          ),
        ),
      ],
    );
  }
}
