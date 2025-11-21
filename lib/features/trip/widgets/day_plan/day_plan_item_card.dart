import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/features/trip/model/day_plan_item_model.dart';
import 'package:trip_planner/features/trip/controller/watch_trip_provider.dart';

class DayPlanItemCard extends ConsumerWidget {
  final DayPlanItem item;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final String tripId;

  const DayPlanItemCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onDelete,
    required this.tripId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: ValueKey(item.id),
        direction: DismissDirection.endToStart,
        confirmDismiss: (direction) async {
          return await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Usuń aktywność'),
              content: Text('Czy na pewno chcesz usunąć "${item.title}"?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Anuluj'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Usuń'),
                ),
              ],
            ),
          );
        },
        onDismissed: (direction) => onDelete(),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.delete, color: Colors.white, size: 28),
              SizedBox(height: 4),
              Text(
                'Usuń',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: _getBorderColor(),
              width: 2,
            ),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTimeColumn(),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildContentColumn(ref),
                  ),
                  _buildTrailingIcon(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeColumn() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _getTimeBackgroundColor(),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            _formatTime(item.startTime),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _getTimeTextColor(),
            ),
          ),
          if (item.endTime != null) ...[
            const SizedBox(height: 2),
            Icon(
              Icons.arrow_downward,
              size: 12,
              color: _getTimeTextColor(),
            ),
            const SizedBox(height: 2),
            Text(
              _formatTime(item.endTime!),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _getTimeTextColor(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContentColumn(WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildIcon(),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                item.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        if (item.markerId != null) ...[
          const SizedBox(height: 6),
          _buildLocationInfo(ref),
        ],
        if (item.description != null && item.description!.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            item.description!,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            _buildDurationChip(),
            if (item.hasExpenses) _buildExpenseChip(),
            if (item.isMarkerLinked && item.type == DayPlanItemType.marker)
              _buildMarkerChip(),
            if (item.isMarkerLinked && item.type == DayPlanItemType.custom)
              _buildLocationChip(),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationInfo(WidgetRef ref) {
    final tripAsync = ref.watch(watchTripProvider(tripId));

    return tripAsync.when(
      data: (trip) {
        final marker = trip.markerPoints.firstWhere(
          (m) => m.id == item.markerId,
          orElse: () => null as dynamic,
        );

        if (marker == null) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: item.type == DayPlanItemType.marker
                ? Colors.blue.shade50
                : Colors.green.shade50,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: item.type == DayPlanItemType.marker
                  ? Colors.blue.shade200
                  : Colors.green.shade200,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_on,
                size: 14,
                color: item.type == DayPlanItemType.marker
                    ? Colors.blue.shade700
                    : Colors.green.shade700,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  marker.name ?? 'Bez nazwy',
                  style: TextStyle(
                    fontSize: 12,
                    color: item.type == DayPlanItemType.marker
                        ? Colors.blue.shade900
                        : Colors.green.shade900,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildIcon() {
    IconData iconData;
    Color iconColor;

    if (item.type == DayPlanItemType.marker) {
      iconData = Icons.place;
      iconColor = Colors.blue.shade700;
    } else {
      iconData = _getCustomIcon();
      iconColor = Colors.green.shade700;
    }

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        size: 20,
        color: iconColor,
      ),
    );
  }

  Widget _buildDurationChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer_outlined,
            size: 14,
            color: Colors.grey.shade700,
          ),
          const SizedBox(width: 4),
          Text(
            _formatDuration(item.durationMinutes),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.account_balance_wallet,
            size: 14,
            color: Colors.orange.shade700,
          ),
          const SizedBox(width: 4),
          Text(
            '${item.totalExpense.toStringAsFixed(2)} PLN',
            style: TextStyle(
              fontSize: 12,
              color: Colors.orange.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarkerChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.map,
            size: 14,
            color: Colors.blue.shade700,
          ),
          const SizedBox(width: 4),
          Text(
            'Z mapy',
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.place,
            size: 14,
            color: Colors.green.shade700,
          ),
          const SizedBox(width: 4),
          Text(
            'Lokalizacja',
            style: TextStyle(
              fontSize: 12,
              color: Colors.green.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrailingIcon() {
    return Column(
      children: [
        Icon(
          Icons.drag_handle,
          color: Colors.grey.shade400,
        ),
        const SizedBox(height: 8),
        Icon(
          Icons.chevron_right,
          color: Colors.grey.shade400,
        ),
      ],
    );
  }

  Color _getBorderColor() {
    if (item.type == DayPlanItemType.marker) {
      return Colors.blue.shade200;
    }
    return Colors.green.shade200;
  }

  Color _getTimeBackgroundColor() {
    if (item.type == DayPlanItemType.marker) {
      return Colors.blue.shade50;
    }
    return Colors.green.shade50;
  }

  Color _getTimeTextColor() {
    if (item.type == DayPlanItemType.marker) {
      return Colors.blue.shade900;
    }
    return Colors.green.shade900;
  }

  IconData _getCustomIcon() {
    if (item.icon != null) {
      switch (item.icon) {
        case 'restaurant':
          return Icons.restaurant;
        case 'hotel':
          return Icons.hotel;
        case 'local_cafe':
          return Icons.local_cafe;
        case 'shopping':
          return Icons.shopping_bag;
        default:
          return Icons.event;
      }
    }

    final title = item.title.toLowerCase();
    if (title.contains('śniadanie') ||
        title.contains('obiad') ||
        title.contains('kolacja')) {
      return Icons.restaurant;
    } else if (title.contains('hotel') || title.contains('nocleg')) {
      return Icons.hotel;
    } else if (title.contains('kawa') || title.contains('kawiarnia')) {
      return Icons.local_cafe;
    } else if (title.contains('zakupy')) {
      return Icons.shopping_bag;
    }

    return Icons.event;
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;

    if (hours > 0 && mins > 0) {
      return '${hours}h ${mins}min';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${mins}min';
    }
  }
}
