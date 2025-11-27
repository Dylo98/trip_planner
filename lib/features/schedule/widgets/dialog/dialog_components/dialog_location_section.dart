import 'package:flutter/material.dart';
import 'package:trip_planner/core/theme/colors.dart';
import 'package:trip_planner/core/theme/input_style.dart';
import 'package:trip_planner/core/theme/text_style.dart';
import 'package:trip_planner/features/schedule/utils/location_name.dart';
import 'package:trip_planner/features/trip/model/marker_point_model.dart';

class DialogLocationSection extends StatelessWidget {
  final String tripId;
  final MarkerPoint? selectedMarker;
  final ValueChanged<MarkerPoint?> onMarkerSelected;
  final VoidCallback onShowPicker;

  const DialogLocationSection({
    super.key,
    required this.tripId,
    required this.selectedMarker,
    required this.onMarkerSelected,
    required this.onShowPicker,
  });

  @override
  Widget build(BuildContext context) {
    final hasLocation = selectedMarker != null;

    final baseText = hasLocation
        ? (selectedMarker!.name ??
            selectedMarker!.description ??
            'Wybrana lokalizacja')
        : null;

    final locationText = hasLocation
        ? LocationName.getShortName(
            baseText,
            fallback: 'Wybrana lokalizacja',
          )
        : '';

    final decoration = AppInputStyle.inputDecoration(
      icon: Icons.location_on,
      labelText: hasLocation ? '' : 'Dodaj lokalizację',
    ).copyWith(
      suffixIcon: hasLocation
          ? IconButton(
              icon: const Icon(Icons.clear, size: 20),
              onPressed: () => onMarkerSelected(null),
              color: AppColors.textSecondary,
            )
          : const Icon(Icons.arrow_drop_down),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onShowPicker,
          borderRadius: BorderRadius.circular(50),
          child: InputDecorator(
            isEmpty: !hasLocation,
            decoration: decoration,
            child: hasLocation
                ? Text(
                    locationText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyTextSecondary.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}
