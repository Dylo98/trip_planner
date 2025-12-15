import 'package:flutter/material.dart';
import 'package:trip_planner/core/utils/action_lock.dart';
import 'package:trip_planner/features/trip/model/trip_model.dart';
import 'package:trip_planner/features/trip/widgets/trip_card/trip_card.dart';

class SharedTripItem extends StatelessWidget {
  const SharedTripItem({
    super.key,
    required this.trip,
    required this.openTripLock,
  });

  final Trip trip;
  final ActionLock openTripLock;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TripCard(
          trip: trip,
          openTripLock: openTripLock,
        ),
      ],
    );
  }
}
