import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/core/utils/validators.dart';
import 'package:trip_planner/features/auth/widgets/authflashbars/error_flushbar.dart';
import 'package:trip_planner/features/trip/controller/trip_form_provider.dart';
import 'package:trip_planner/features/trip/controller/trip_markers_provider.dart';
import 'package:trip_planner/features/trip/controller/trip_photo_provider.dart';

class TripFormService {
  final WidgetRef ref;
  final BuildContext context;

  TripFormService({required this.ref, required this.context});

  Future<void> saveTrip(GlobalKey<FormState> formKey) async {
    if (!formKey.currentState!.validate()) return;

    final tripState = ref.read(tripFormProvider);

    final dateError = Validators.validateTripDates(
      startDate: tripState.startDate,
      endDate: tripState.endDate,
    );

    if (dateError != null) {
      ErrorFlushbar.show(context: context, message: dateError);
      return;
    }

    final image = ref.read(tripPhotoProvider);
    final markers = ref.read(tripMarkersProvider);

    await ref.read(tripFormProvider.notifier).save(image, markers);
    ref.read(tripMarkersProvider.notifier).clear();
    ref.read(tripPhotoProvider.notifier).state = null;

    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }
}
