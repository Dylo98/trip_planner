import 'package:flutter/material.dart';
import 'package:trip_planner/features/trip/model/trip_model.dart';
import 'package:trip_planner/features/trip/utils/trip_status_helper.dart';

class TripStatusChip extends StatelessWidget {
  const TripStatusChip({
    super.key,
    required this.trip,
  });

  final Trip trip;

  @override
  Widget build(BuildContext context) {
    final statusHelper = TripStatusHelper(trip.status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusHelper.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusHelper.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusHelper.icon, size: 16, color: statusHelper.color),
          const SizedBox(width: 6),
          Text(
            statusHelper.label,
            style: TextStyle(
              color: statusHelper.color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
