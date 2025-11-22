import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:trip_planner/features/trip/model/marker_point_model.dart';
import 'package:trip_planner/features/timeline/utils/timeline_style_helper.dart';

class TimelineTileWidget extends StatelessWidget {
  final MarkerPoint marker;
  final int index;
  final bool isFirst;
  final bool isLast;
  final bool isLeft;

  const TimelineTileWidget({
    super.key,
    required this.marker,
    required this.index,
    required this.isFirst,
    required this.isLast,
    required this.isLeft,
  });

  @override
  Widget build(BuildContext context) {
    final styleHelper = TimelineStyleHelper(index: index);

    return TimelineTile(
      alignment: TimelineAlign.center,
      isFirst: isFirst,
      isLast: isLast,
      beforeLineStyle: LineStyle(
        color: styleHelper.getLineColor(),
        thickness: 4,
      ),
      afterLineStyle: LineStyle(
        color: styleHelper.getNextLineColor(),
        thickness: 4,
      ),
      indicatorStyle: IndicatorStyle(
        width: 70,
        height: 70,
        indicator: _buildIndicator(styleHelper),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      startChild: isLeft ? _buildCard(context, styleHelper) : null,
      endChild: !isLeft ? _buildCard(context, styleHelper) : null,
    );
  }

  Widget _buildIndicator(TimelineStyleHelper styleHelper) {
    final hasImage = marker.imageUrl != null && marker.imageUrl!.isNotEmpty;

    return Container(
      decoration: styleHelper.getIndicatorDecoration(),
      child:
          hasImage ? _buildImageIndicator(styleHelper) : _buildIconIndicator(),
    );
  }

  Widget _buildImageIndicator(TimelineStyleHelper styleHelper) {
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: marker.imageUrl!.first,
        fit: BoxFit.cover,
        width: 70,
        height: 70,
        placeholder: (context, url) => Container(
          decoration: styleHelper.getGradientDecoration(),
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
          decoration: styleHelper.getGradientDecoration(),
          child: const Icon(
            Icons.location_on,
            color: Colors.white,
            size: 36,
          ),
        ),
      ),
    );
  }

  Widget _buildIconIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            TimelineStyleHelper.getTransportIcon(marker.transportMode),
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
    );
  }

  Widget _buildCard(BuildContext context, TimelineStyleHelper styleHelper) {
    return Padding(
      padding: EdgeInsets.only(
        left: isLeft ? 0 : 24,
        right: isLeft ? 24 : 0,
        bottom: 8,
      ),
      child: Card(
        elevation: 6,
        shadowColor: styleHelper.color.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          decoration: styleHelper.getCardDecoration(),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TimelineCardHeader(
                  index: index,
                  markerName: marker.name,
                  styleHelper: styleHelper,
                ),
                if (marker.description != null &&
                    marker.description!.isNotEmpty)
                  _TimelineCardDescription(description: marker.description!),
                if (marker.expense != null && marker.expense! > 0)
                  _TimelineCardExpense(expense: marker.expense!),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TimelineCardHeader extends StatelessWidget {
  final int index;
  final String? markerName;
  final TimelineStyleHelper styleHelper;

  const _TimelineCardHeader({
    required this.index,
    required this.markerName,
    required this.styleHelper,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          decoration: styleHelper.getBadgeDecoration(),
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
            TimelineStyleHelper.getCleanPlaceName(markerName),
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
    );
  }
}

class _TimelineCardDescription extends StatelessWidget {
  final String description;

  const _TimelineCardDescription({required this.description});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Text(
        description,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey[700],
          height: 1.4,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _TimelineCardExpense extends StatelessWidget {
  final double expense;

  const _TimelineCardExpense({required this.expense});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Container(
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
              '${expense.toStringAsFixed(0)} PLN',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.green.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
