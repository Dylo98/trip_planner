import 'package:flutter/material.dart';
import 'package:trip_planner/features/trip/services/google_places/google_places_models.dart';
import 'package:trip_planner/features/trip/widgets/nearby_places/widgets/place_details/components/place_details_section_title.dart';
import 'package:trip_planner/features/trip/widgets/nearby_places/widgets/place_details/components/place_details_review_card.dart';

class PlaceDetailsReviewsSection extends StatelessWidget {
  const PlaceDetailsReviewsSection({
    super.key,
    required this.reviews,
  });

  final List<PlaceReview> reviews;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PlaceDetailsSectionTitle(title: 'Opinie'),
        ...reviews.map((review) => PlaceDetailsReviewCard(review: review)),
      ],
    );
  }
}
