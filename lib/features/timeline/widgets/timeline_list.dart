import 'package:flutter/material.dart';
import 'package:trip_planner/features/timeline/widgets/timeline_tile_widget.dart';

class TimelineList extends StatelessWidget {
  final List markers;
  final String? tripId;

  const TimelineList({
    super.key,
    required this.markers,
    this.tripId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blue.shade50.withValues(alpha: 0.3),
            Colors.white,
          ],
        ),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 32),
        itemCount: markers.length,
        itemBuilder: (context, index) {
          final marker = markers[index];
          final isFirst = index == 0;
          final isLast = index == markers.length - 1;
          final isLeft = index % 2 == 0;

          return TimelineTileWidget(
            marker: marker,
            index: index,
            isFirst: isFirst,
            isLast: isLast,
            isLeft: isLeft,
            tripId: tripId,
          );
        },
      ),
    );
  }
}
