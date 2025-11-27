import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trip_planner/core/theme/colors.dart';
import 'package:trip_planner/core/theme/text_style.dart';
import 'package:trip_planner/features/schedule/screens/activity_screen.dart';

class DayPlanCard extends StatelessWidget {
  final DateTime date;
  final int dayNumber;
  final int activityCount;
  final String tripId;

  const DayPlanCard({
    super.key,
    required this.date,
    required this.dayNumber,
    required this.activityCount,
    required this.tripId,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, d MMMM yyyy', 'pl_PL');
    final formattedDate = dateFormat.format(date);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      color: AppColors.limeSlice,
      child: InkWell(
        onTap: () => _navigateToDayDetail(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildDayBadge(),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDayInfo(formattedDate),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.limeSliceDark,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDayBadge() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Dzień', style: AppTextStyles.bodyText),
          Text('$dayNumber', style: AppTextStyles.bodyTextSecondary),
        ],
      ),
    );
  }

  Widget _buildDayInfo(String formattedDate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(formattedDate, style: AppTextStyles.bodyLarge),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              Icons.event_available,
              size: 16,
              color: activityCount > 0
                  ? AppColors.primaryDark
                  : AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              activityCount > 0
                  ? '$activityCount ${activityCount == 1 ? "aktywność" : "aktywności"}'
                  : 'Brak aktywności',
              style: TextStyle(
                fontSize: 13,
                color: activityCount > 0
                    ? AppColors.primaryDark
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _navigateToDayDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ActivityScreen(
          tripId: tripId,
          date: date,
          dayNumber: dayNumber,
        ),
      ),
    );
  }
}
