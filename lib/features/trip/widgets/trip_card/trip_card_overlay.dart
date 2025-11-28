import 'package:flutter/material.dart';
import 'package:trip_planner/core/theme/colors.dart';
import 'package:trip_planner/features/trip/model/trip_model.dart';
import 'package:trip_planner/features/trip/widgets/trip_card/trip_card_content.dart';
import 'package:trip_planner/features/trip/widgets/trip_card/trip_status_badge.dart';

class TripCardOverlay extends StatelessWidget {
  const TripCardOverlay({
    super.key,
    required this.trip,
    required this.formattedStartDate,
    required this.totalBudget,
  });

  final Trip trip;
  final String formattedStartDate;
  final double totalBudget;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        decoration: _buildOverlayDecoration(),
        child: Stack(
          children: [
            TripStatusBadge(status: trip.status),
            TripCardContent(
              tripName: trip.name,
              formattedStartDate: formattedStartDate,
              totalBudget: totalBudget,
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _buildOverlayDecoration() {
    return BoxDecoration(
      color: AppColors.black.withValues(alpha: 0.5),
      border: Border.all(
        color: AppColors.white,
        width: 5,
      ),
      borderRadius: BorderRadius.circular(30),
    );
  }
}
