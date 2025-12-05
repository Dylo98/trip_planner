import 'package:flutter/material.dart';
import 'package:trip_planner/core/theme/text_style.dart';
import 'package:trip_planner/features/trip/widgets/nearby_places/widgets/place_card/components/place_card_rating.dart';

class PlaceCardInfo extends StatelessWidget {
  const PlaceCardInfo({
    super.key,
    required this.name,
    this.rating,
    this.userRatingsTotal,
  });

  final String name;
  final double? rating;
  final int? userRatingsTotal;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          name,
          style: AppTextStyles.heading4,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (rating != null) ...[
          const SizedBox(height: 4),
          PlaceCardRating(
            rating: rating!,
            userRatingsTotal: userRatingsTotal,
          ),
        ],
      ],
    );
  }
}
