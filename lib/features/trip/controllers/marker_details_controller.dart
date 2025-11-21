import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:trip_planner/core/utils/action_lock.dart';
import 'package:trip_planner/features/trip/model/marker_point_model.dart';
import 'package:trip_planner/features/trip/widgets/marker_details_sheet/marker_details_sheet.dart';

/// Kontroler odpowiedzialny za wyświetlanie szczegółów markera
class MarkerDetailsController {
  final ActionLock _sheetLock = ActionLock();

  bool get isSheetLocked => _sheetLock.isBusy;

  Future<void> showMarkerDetails(
    BuildContext context,
    MarkerPoint marker, {
    String? tripId,
  }) async {
    await _sheetLock.run(() async {
      if (!context.mounted) return;

      await showMaterialModalBottomSheet(
        context: context,
        builder: (_) => MarkerDetailsSheet(
          marker: marker,
          tripId: tripId,
        ),
      );
    });
  }
}
