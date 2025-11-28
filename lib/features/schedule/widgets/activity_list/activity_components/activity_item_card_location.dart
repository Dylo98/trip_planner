import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/core/theme/colors.dart';
import 'package:trip_planner/core/theme/text_style.dart';
import 'package:trip_planner/features/schedule/model/day_plan_item_model.dart';
import 'package:trip_planner/features/schedule/controller/day_plan_provider.dart';
import 'package:trip_planner/core/utils/location_name.dart';

class ActivityItemCardLocation extends ConsumerWidget {
  final DayPlanItem item;
  final String tripId;

  const ActivityItemCardLocation({
    super.key,
    required this.item,
    required this.tripId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (item.markerId == null) {
      return const SizedBox.shrink();
    }

    final marker = ref.watch(
      markerByIdProvider(MarkerAndTripId(tripId, item.markerId!)),
    );

    if (marker == null) {
      return const SizedBox.shrink();
    }

    final shortName = LocationName.getShortName(marker.name);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.location_on,
            size: 14,
            color: AppColors.primaryDark,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              shortName,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primaryDark,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
