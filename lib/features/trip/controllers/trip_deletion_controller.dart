import 'package:flutter/material.dart';
import 'package:trip_planner/features/trip/model/trip_model.dart';
import 'package:trip_planner/features/trip/services/trip_service.dart';
import 'package:trip_planner/features/trip/utils/confirmation_dialog_helper.dart';
import 'package:trip_planner/core/widgets/app_notifications.dart';

/// Kontroler obsługujący usuwanie wycieczek
class TripDeletionController {
  final BuildContext context;
  final TripService tripService;

  TripDeletionController({
    required this.context,
    required this.tripService,
  });

  Future<bool> handleTripDeletion(Trip trip) async {
    final confirmed = await showConfirmationDialog(trip.name);

    if (!confirmed || !context.mounted) {
      return false;
    }

    try {
      await tripService.deleteTrip(trip.id);
      showSuccessMessage(trip.name);
      return true;
    } catch (e) {
      showErrorMessage(e);
      return false;
    }
  }

  Future<bool> showConfirmationDialog(String tripName) async {
    return await ConfirmationDialogHelper.showDeleteTripDialog(
      context,
      tripName,
    );
  }

  void showSuccessMessage(String tripName) {
    if (!context.mounted) return;
    AppNotifications.showSuccess(
      context: context,
      message: 'Usunięto podróż "$tripName"',
    );
  }

  void showErrorMessage(Object error) {
    if (!context.mounted) return;

    AppNotifications.showError(
      context: context,
      message: 'Nie udało się usunąć podróży. Spróbuj ponownie.',
    );
  }
}
