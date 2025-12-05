import 'package:flutter/material.dart';
import 'package:trip_planner/core/theme/colors.dart';
import 'package:trip_planner/core/theme/text_style.dart';

class PlaceCardRating extends StatelessWidget {
  const PlaceCardRating({
    super.key,
    required this.rating,
    this.userRatingsTotal,
  });

  final double rating;
  final int? userRatingsTotal;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.star,
          size: 14,
          color: AppColors.star,
        ),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: AppTextStyles.bodySmall,
        ),
        if (userRatingsTotal != null) ...[
          const SizedBox(width: 2),
          Text(
            '($userRatingsTotal)',
            style: AppTextStyles.bodyTextSecondary,
          ),
        ],
      ],
    );
  }
}
