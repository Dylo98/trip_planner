import 'package:flutter/material.dart';
import 'package:trip_planner/core/theme/colors.dart';
import 'package:trip_planner/core/theme/text_style.dart';
import 'package:trip_planner/features/trip/services/google_places/google_places_models.dart';

class PlaceDetailsReviewCard extends StatelessWidget {
  const PlaceDetailsReviewCard({
    super.key,
    required this.review,
  });

  final PlaceReview review;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.limeSlice,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  review.authorName,
                  style: AppTextStyles.bodyText,
                ),
                const Spacer(),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      size: 16,
                      color: AppColors.star,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      review.rating.toString(),
                      style: AppTextStyles.bodyText,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              review.relativeTimeDescription,
              style: AppTextStyles.bodyTextSecondary,
            ),
            const SizedBox(height: 8),
            Text(
              review.text,
              style: AppTextStyles.bodyTextSecondaryBig,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
