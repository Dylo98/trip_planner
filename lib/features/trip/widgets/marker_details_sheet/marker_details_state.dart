import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trip_planner/features/trip/model/marker_point_model.dart';
import 'package:trip_planner/features/budget/model/expense_item_model.dart';
import 'package:trip_planner/features/trip/services/trip_service.dart';
import 'package:trip_planner/features/trip/providers/trip_markers_provider.dart';
import 'package:trip_planner/core/utils/action_lock.dart';

class MarkerDetailsState {
  final WidgetRef ref;
  final BuildContext context;
  final MarkerPoint marker;
  final String? tripId;
  final void Function(MarkerPoint)? onUpdate;

  MarkerPoint _currentMarker;

  final pickImageLock = ActionLock();
  final deleteLock = ActionLock();
  final updateExpensesLock = ActionLock();

  bool get isNewTrip => tripId == null;

  MarkerDetailsState({
    required this.ref,
    required this.context,
    required this.marker,
    this.tripId,
    this.onUpdate,
  }) : _currentMarker = marker;

  MarkerPoint get currentMarker => _currentMarker;

  Future<void> updateExpenses(
    List<ExpenseItem> expenses,
    Function(void Function()) setState,
  ) async {
    await updateExpensesLock.run(() async {
      if (isNewTrip) {
        final updated = _currentMarker.copyWith(expenses: expenses);
        setState(() => _currentMarker = updated);
        onUpdate?.call(updated);

        ref.read(tripMarkersProvider.notifier).updateMarker(
              _currentMarker.id,
              updated,
            );
      } else {
        await ref.read(tripServiceProvider).updateMarkerExpenses(
              tripId: tripId!,
              markerId: _currentMarker.id,
              expenses: expenses,
            );
      }
    });
  }

  @Deprecated('Użyj updateExpenses zamiast updateExpense')
  Future<void> updateExpense(
    double expense,
    Function(void Function()) setState,
  ) async {
    final expenseItem = ExpenseItem(
      id: '${_currentMarker.id}_default',
      title: 'Wydatek',
      amount: expense,
    );
    await updateExpenses([expenseItem], setState);
  }

  Future<void> updateDescription(
    String description,
    Function(void Function()) setState,
  ) async {
    if (isNewTrip) {
      final updated = _currentMarker.copyWith(description: description);
      setState(() => _currentMarker = updated);
      onUpdate?.call(updated);

      ref.read(tripMarkersProvider.notifier).updateMarker(
            _currentMarker.id,
            updated,
          );
    } else {
      await ref.read(tripServiceProvider).updateMarkerDescription(
            tripId: tripId!,
            markerId: _currentMarker.id,
            description: description,
          );
    }
  }

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
            );
      }
    });
  }

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
