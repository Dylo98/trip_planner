import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:trip_planner/features/trip/controller/watch_trip_provider.dart';
import 'package:trip_planner/features/trip/model/marker_point_model.dart';

class TripDetailsTimelineScreen extends ConsumerWidget {
  final String tripId;

  const TripDetailsTimelineScreen({super.key, required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripAsync = ref.watch(watchTripProvider(tripId));

    return Scaffold(
      body: tripAsync.when(
        data: (trip) {
          final markers = trip.markerPoints;

          if (markers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.timeline,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Brak punktów na osi czasu',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Dodaj miejsca do swojej podróży',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

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

                return _CenteredTimelineTile(
                  marker: marker,
                  index: index,
                  isFirst: isFirst,
                  isLast: isLast,
                  isLeft: isLeft,
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 16),
              Text('Błąd: $e'),
            ],
          ),
        ),
      ),
    );
  }
}

class _CenteredTimelineTile extends StatelessWidget {
  final MarkerPoint marker;
  final int index;
  final bool isFirst;
  final bool isLast;
  final bool isLeft;

  const _CenteredTimelineTile({
    required this.marker,
    required this.index,
    required this.isFirst,
    required this.isLast,
    required this.isLeft,
  });

  @override
  Widget build(BuildContext context) {
    return TimelineTile(
      alignment: TimelineAlign.center,
      isFirst: isFirst,
      isLast: isLast,
      beforeLineStyle: LineStyle(
        color: _getGradientColor(index),
        thickness: 4,
      ),
      afterLineStyle: LineStyle(
        color: _getGradientColor(index + 1),
        thickness: 4,
      ),
      indicatorStyle: IndicatorStyle(
        width: 70,
        height: 70,
        indicator: _buildCenterIndicator(),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      startChild: isLeft ? _buildCard(context) : null,
      endChild: !isLeft ? _buildCard(context) : null,
    );
  }

  Widget _buildCenterIndicator() {
    final hasImage = marker.imageUrl != null && marker.imageUrl!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getGradientColor(index),
            _getGradientColor(index).withValues(alpha: 0.7),
          ],
        ),
        border: Border.all(
          color: Colors.white,
          width: 4,
        ),
        boxShadow: [
          BoxShadow(
            color: _getGradientColor(index).withValues(alpha: 0.4),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: hasImage
          ? ClipOval(
              child: CachedNetworkImage(
                imageUrl: marker.imageUrl!.first,
                fit: BoxFit.cover,
                width: 70,
                height: 70,
                placeholder: (context, url) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _getGradientColor(index),
                        _getGradientColor(index).withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _getGradientColor(index),
                        _getGradientColor(index).withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getTransportIcon(marker.transportMode),
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildCard(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: isLeft ? 0 : 24,
        right: isLeft ? 24 : 0,
        bottom: 8,
      ),
      child: Card(
        elevation: 6,
        shadowColor: _getGradientColor(index).withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                _getGradientColor(index).withValues(alpha: 0.05),
              ],
            ),
            border: Border.all(
              color: _getGradientColor(index).withValues(alpha: 0.2),
              width: 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getGradientColor(index),
                            _getGradientColor(index).withValues(alpha: 0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getCleanPlaceName(marker.name),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (marker.description != null &&
                    marker.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      marker.description!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (marker.expense != null && marker.expense! > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.green.shade200,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.payments,
                                size: 14,
                                color: Colors.green.shade700,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${marker.expense!.toStringAsFixed(0)} PLN',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getGradientColor(int idx) {
    final colors = [
      Colors.purple,
      Colors.pink,
      Colors.blue,
      Colors.orange,
      Colors.teal,
      Colors.indigo,
      Colors.deepOrange,
      Colors.cyan,
    ];
    return colors[idx % colors.length];
  }

  IconData _getTransportIcon(String? mode) {
    if (mode == null) return Icons.location_on;
    switch (mode.toLowerCase()) {
      case 'car':
        return Icons.directions_car;
      case 'bus':
        return Icons.directions_bus;
      case 'train':
        return Icons.train;
      case 'plane':
        return Icons.flight;
      case 'walk':
        return Icons.directions_walk;
      case 'bike':
        return Icons.directions_bike;
      case 'boat':
        return Icons.directions_boat;
      default:
        return Icons.location_on;
    }
  }

  String _getCleanPlaceName(String? fullName) {
    if (fullName == null || fullName.isEmpty) return 'Bez nazwy';

    if (fullName.contains(',')) {
      return fullName.split(',').first.trim();
    }

    return fullName;
  }
}
