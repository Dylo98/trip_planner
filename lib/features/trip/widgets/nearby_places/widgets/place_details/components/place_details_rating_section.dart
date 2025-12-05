import 'package:flutter/material.dart';
import 'package:trip_planner/core/theme/colors.dart';
import 'package:trip_planner/features/trip/services/google_places/google_places_models.dart';

class PlaceDetailsRatingSection extends StatelessWidget {
  const PlaceDetailsRatingSection({
    super.key,
    required this.name,
    this.rating,
    this.userRatingsTotal,
    this.openingHoursStatus,
  });

  final String name;
  final double? rating;
  final int? userRatingsTotal;
  final OpeningHoursStatus? openingHoursStatus;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            if (rating != null) ...[
              Icon(
                Icons.star,
                color: Colors.amber.shade700,
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                rating!.toStringAsFixed(1),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              if (userRatingsTotal != null) ...[
                const SizedBox(width: 4),
                Text(
                  '($userRatingsTotal opinii)',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ],
            const Spacer(),
            if (openingHoursStatus != null) _buildOpenNowChip(),
          ],
        ),
      ],
    );
  }

  Widget _buildOpenNowChip() {
    final isOpen = openingHoursStatus!.openNow;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isOpen ? AppColors.limeSliceLight : AppColors.redLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isOpen ? AppColors.primary : AppColors.red,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOpen ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: isOpen ? AppColors.primary : AppColors.red,
          ),
          const SizedBox(width: 4),
          Text(
            isOpen ? 'Otwarte' : 'Zamknięte',
            style: TextStyle(
              color: isOpen ? AppColors.primary : AppColors.red,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
