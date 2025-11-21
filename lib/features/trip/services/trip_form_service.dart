import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/core/utils/validators.dart';
import 'package:trip_planner/core/widgets/app_notifications.dart';
import 'package:trip_planner/features/trip/providers/trip_form_provider.dart';
import 'package:trip_planner/features/trip/providers/trip_markers_provider.dart';
import 'package:trip_planner/features/trip/providers/trip_photo_provider.dart';
import 'package:trip_planner/features/trip/providers/get_trip_provider.dart';

class TripFormService {
  final WidgetRef ref;
  final BuildContext context;

  TripFormService({required this.ref, required this.context});

  Future<void> saveTrip(GlobalKey<FormState> formKey) async {
    if (!formKey.currentState!.validate()) return;

    final tripState = ref.read(tripFormProvider);

    final existingTrips = ref.read(getTripProvider).value ?? [];

    final dateError = Validators.validateTripDatesWithConflicts(
      startDate: tripState.startDate,
      endDate: tripState.endDate,
      existingTrips: existingTrips,
      currentTripId: null,
    );

    if (dateError != null) {
      AppNotifications.showError(context: context, message: dateError);
      return;
    }

    final image = ref.read(tripPhotoProvider);
    final markers = ref.read(tripMarkersProvider);

    try {
      await ref.read(tripFormProvider.notifier).save(image, markers);
      ref.read(tripMarkersProvider.notifier).clear();
      ref.read(tripPhotoProvider.notifier).state = null;

      if (context.mounted) {
        AppNotifications.showSuccess(
          context: context,
          message: 'Podróż została zapisana',
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (context.mounted) {
        AppNotifications.showError(
          context: context,
          message: e.toString(),
        );
      }
    }
  }
}
