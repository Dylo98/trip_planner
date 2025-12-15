import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trip_planner/core/utils/dialog_utils.dart';
import 'package:trip_planner/core/widgets/app_notifications.dart';
import 'package:trip_planner/core/widgets/dialog/dialog_confirmation.dart';
import 'package:trip_planner/features/auth/providers/user_provider.dart';
import 'package:trip_planner/features/trip/model/trip_model.dart';
import 'package:trip_planner/features/trip/services/trip_service.dart';
import 'package:trip_planner/features/trip/widgets/shared/date_change_dialog.dart';
import 'package:trip_planner/features/trip/widgets/shared/trip_name_edit_dialog.dart';

class TripDetailsEditController {
  final WidgetRef ref;
  final BuildContext context;
  final Trip trip;

  TripDetailsEditController({
    required this.ref,
    required this.context,
    required this.trip,
  });

  TripService get _tripService => ref.read(tripServiceProvider);

  Future<bool> handlePhotoChange() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image == null) {
        return false;
      }

      if (!context.mounted) return false;

      try {
        final File imageFile = File(image.path);

        await DialogUtils.executeWithLoading(context, () async {
          final String photoUrl = await _tripService.uploadTripImage(
            imageFile,
            trip.id,
          );
          await _tripService.updateTripPhoto(trip.id, photoUrl);
        });

        if (context.mounted) {
          AppNotifications.showSuccess(
            context: context,
            message: 'Zdjęcie zostało dodane',
          );
          return true;
        }

        return false;
      } catch (e) {
        if (context.mounted) {
          AppNotifications.showError(
            context: context,
            message: 'Nie udało się dodać zdjęcia. Spróbuj ponownie.',
          );
        }

        return false;
      }
    } catch (e) {
      if (context.mounted) {
        AppNotifications.showError(
          context: context,
          message: 'Nie udało się wybrać zdjęcia',
        );
      }

      return false;
    }
  }

  Future<bool> handlePhotoRemoval() async {
    final confirmed = await ConfirmationDialogs.deletePhoto(
      context: context,
    );

    if (!confirmed || !context.mounted) return false;

    try {
      await DialogUtils.executeWithLoading(context, () async {
        await _tripService.updateTripPhoto(trip.id, null);
      });

      if (context.mounted) {
        AppNotifications.showSuccess(
          context: context,
          message: 'Zdjęcie zostało usunięte',
        );
        return true;
      }

      return false;
    } catch (e) {
      if (context.mounted) {
        AppNotifications.showError(
          context: context,
          message: 'Nie udało się usunąć zdjęcia. Spróbuj ponownie.',
        );
      }

      return false;
    }
  }

  Future<bool> handleDateChange() async {
    try {
      final userAsync = ref.read(authStateProvider);
      final user = userAsync.value;

      if (user == null) {
        AppNotifications.showError(
          context: context,
          message: 'Nie jesteś zalogowany',
        );

        return false;
      }

      final allTripsStream = _tripService.getTrips(user.uid);
      final allTrips = await allTripsStream.first;

      if (!context.mounted) return false;

      final result = await showDialog<DateChangeResult>(
        context: context,
        builder: (context) => DateChangeDialog(
          trip: trip,
          existingTrips: allTrips,
        ),
      );

      if (result == null || !context.mounted) return false;

      try {
        await DialogUtils.executeWithLoading(context, () async {
          await _tripService.updateTripDates(
            trip.id,
            result.startDate,
            result.endDate,
          );
        });

        if (context.mounted) {
          AppNotifications.showSuccess(
            context: context,
            message: 'Daty zostały zaktualizowane',
          );
          return true;
        }

        return false;
      } catch (e) {
        if (context.mounted) {
          AppNotifications.showError(
            context: context,
            message: 'Nie udało się zaktualizować dat. Spróbuj ponownie.',
          );
        }

        return false;
      }
    } catch (e) {
      if (context.mounted) {
        AppNotifications.showError(
          context: context,
          message: 'Wystąpił nieoczekiwany błąd',
        );
      }

      return false;
    }
  }

  Future<bool> handleNameChange() async {
    final result = await TripNameEditDialog.show(
      context: context,
      currentName: trip.name,
    );

    if (result == null || !context.mounted) return false;

    try {
      await DialogUtils.executeWithLoading(context, () async {
        await _tripService.updateTripName(trip.id, result);
      });

      if (context.mounted) {
        AppNotifications.showSuccess(
          context: context,
          message: 'Nazwa została zmieniona',
        );
        return true;
      }

      return false;
    } catch (e) {
      if (context.mounted) {
        AppNotifications.showError(
          context: context,
          message: 'Nie udało się zmienić nazwy. Spróbuj ponownie.',
        );
      }

      return false;
    }
  }
}
