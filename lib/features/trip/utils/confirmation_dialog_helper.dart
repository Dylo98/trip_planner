import 'package:flutter/material.dart';
import 'package:trip_planner/core/widgets/dialog/dialog_confirmation.dart';

class ConfirmationDialogHelper {
  static Future<bool> showDeleteMarkerDialog(
    BuildContext context,
  ) async {
    return ConfirmationDialogs.delete(
      context: context,
      title: 'Usuń punkt podróży',
      content: 'Czy na pewno chcesz usunąć ten punkt podróży?',
    );
  }

  static Future<bool> showDeleteTripDialog(
    BuildContext context,
    String tripName,
  ) async {
    return ConfirmationDialogs.deleteTrip(
      context: context,
      tripName: tripName,
    );
  }
}
