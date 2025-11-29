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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.share, size: 14, color: Colors.blue),
                    SizedBox(width: 4),
                    Text(
                      'Współdzielona',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
