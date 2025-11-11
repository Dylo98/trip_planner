// lib/features/trip/widgets/marker_details_sheet/marker_details_state.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trip_planner/features/trip/model/marker_point_model.dart';
import 'package:trip_planner/features/trip/services/trip_service.dart';
import 'package:trip_planner/features/trip/controller/trip_markers_provider.dart';
import 'package:trip_planner/core/utils/action_lock.dart';

class MarkerDetailsState {
  final WidgetRef ref;
  final BuildContext context;
  final MarkerPoint marker;
  final String? tripId;
  final void Function(MarkerPoint)? onUpdate;

  MarkerPoint _currentMarker;
  DateTime? arrivalDateTime;
  DateTime? departureDateTime;

  // Locks
  final pickImageLock = ActionLock();
  final deleteLock = ActionLock();
  final updateDatesLock = ActionLock();

  bool get isNewTrip => tripId == null;

  MarkerDetailsState({
    required this.ref,
    required this.context,
    required this.marker,
    this.tripId,
    this.onUpdate,
  })  : _currentMarker = marker,
        arrivalDateTime = marker.arrivalDateTime,
        departureDateTime = marker.departureDateTime;

  MarkerPoint get currentMarker => _currentMarker;

  // ✅ UPDATE DATES
  Future<void> updateMarkerDates({
    required DateTime arrival,
    required DateTime departure,
    required Function(void Function()) setState,
  }) async {
    if (isNewTrip) {
      final updated = _currentMarker.copyWith(
        arrivalDateTime: arrival,
        departureDateTime: departure,
      );
      setState(() {
        _currentMarker = updated;
        arrivalDateTime = arrival;
        departureDateTime = departure;
      });
      onUpdate?.call(updated);

      ref.read(tripMarkersProvider.notifier).updateMarker(
            _currentMarker.id,
            updated,
          );
    } else {
      await ref.read(tripServiceProvider).updateMarkerDates(
            tripId: tripId!,
            markerId: _currentMarker.id,
            arrival: arrival,
            departure: departure,
          );
      setState(() {
        arrivalDateTime = arrival;
        departureDateTime = departure;
      });
    }
  }

  // ✅ UPDATE EXPENSE
  Future<void> updateExpense(
    double expense,
    Function(void Function()) setState,
  ) async {
    if (isNewTrip) {
      final updated = _currentMarker.copyWith(expense: expense);
      setState(() => _currentMarker = updated);
      onUpdate?.call(updated);

      ref.read(tripMarkersProvider.notifier).updateMarker(
            _currentMarker.id,
            updated,
          );
    } else {
      await ref.read(tripServiceProvider).updateMarkerExpense(
            tripId: tripId!,
            markerId: _currentMarker.id,
            expense: expense,
          );
    }
  }

  // ✅ PICK AND ADD IMAGE
  Future<void> pickAndAddImage(Function(void Function()) setState) async {
    await pickImageLock.run(() async {
      final picker = ImagePicker();
      final XFile? pickedFile =
          await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;

      final file = File(pickedFile.path);

      if (isNewTrip) {
        final newUrls = List<String>.from(_currentMarker.imageUrl ?? []);
        newUrls.add(file.path);

        final updated = _currentMarker.copyWith(imageUrl: newUrls);
        setState(() => _currentMarker = updated);
        onUpdate?.call(updated);

        ref.read(tripMarkersProvider.notifier).updateMarker(
              _currentMarker.id,
              updated,
            );
      } else {
        await ref.read(tripServiceProvider).addImageToMarker(
              tripId: tripId!,
              markerId: _currentMarker.id,
              image: file,
              arrival: arrivalDateTime,
              departure: departureDateTime,
            );
      }
    });
  }

  // ✅ DELETE MARKER
  Future<void> deleteMarker() async {
    await deleteLock.run(() async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Usuń punkt podróży'),
          content: const Text('Czy na pewno chcesz usunąć ten punkt podróży?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Anuluj'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Usuń'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      if (isNewTrip) {
        ref.read(tripMarkersProvider.notifier).removeMarker(_currentMarker.id);
        Navigator.pop(context);
      } else {
        await ref
            .read(tripServiceProvider)
            .deleteMarkerFromTrip(tripId!, _currentMarker.id);
        if (context.mounted) {
          Navigator.pop(context);
        }
      }
    });
  }
}
