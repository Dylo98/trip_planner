import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:trip_planner/features/trip/model/marker_point_model.dart';
import 'package:trip_planner/features/timeline/utils/timeline_style_helper.dart';
import 'package:trip_planner/features/trip/widgets/marker_details_sheet/marker_details_sheet.dart';

class TimelineTileWidget extends ConsumerWidget {
  final MarkerPoint marker;
  final int index;
  final bool isFirst;
  final bool isLast;
  final bool isLeft;
  final String? tripId;

  const TimelineTileWidget({
    super.key,
    required this.marker,
    required this.index,
    required this.isFirst,
    required this.isLast,
    required this.isLeft,
    this.tripId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      child: hasImage
          ? _buildImageIndicator(styleHelper)
          : _buildIconIndicator(styleHelper),
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

  Widget _buildIconIndicator(TimelineStyleHelper styleHelper) {
    return Container(
      decoration: styleHelper.getGradientDecoration(),
      child: Center(
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
      ),
    );
  }

  Widget _buildCard(BuildContext context, TimelineStyleHelper styleHelper) {
    final totalExpense = marker.totalExpense;

    return Padding(
      padding: EdgeInsets.only(
        left: isLeft ? 0 : 24,
        right: isLeft ? 24 : 0,
        bottom: 8,
      ),
      child: InkWell(
        onTap: () => _showMarkerDetails(context),
        borderRadius: BorderRadius.circular(20),
        child: Card(
          elevation: 8,
          shadowColor: styleHelper.color.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            decoration: styleHelper.getCardDecoration(),
            child: Padding(
              padding: const EdgeInsets.all(16),
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
                  if (totalExpense > 0) ...[
                    const SizedBox(height: 12),
                    _TimelineCardExpense(
                      expense: totalExpense,
                      color: styleHelper.color,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showMarkerDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => MarkerDetailsSheet(
        marker: marker,
        tripId: tripId,
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
    final cleanName = TimelineStyleHelper.getCleanPlaceName(markerName);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: styleHelper.getBadgeDecoration(),
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          cleanName,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            letterSpacing: -0.3,
            height: 1.2,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
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
      padding: const EdgeInsets.only(top: 12),
      child: Text(
        description,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey[600],
          height: 1.5,
        ),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _TimelineCardExpense extends StatelessWidget {
  final double expense;
  final Color color;

  const _TimelineCardExpense({
    required this.expense,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.account_balance_wallet,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            '${expense.toStringAsFixed(0)} PLN',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
