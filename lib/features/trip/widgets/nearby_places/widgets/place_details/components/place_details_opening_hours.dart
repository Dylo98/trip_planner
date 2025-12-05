import 'package:flutter/material.dart';
import 'package:trip_planner/core/theme/text_style.dart';
import 'package:trip_planner/features/trip/widgets/nearby_places/widgets/place_details/components/place_details_section_title.dart';

class PlaceDetailsOpeningHours extends StatelessWidget {
  const PlaceDetailsOpeningHours({
    super.key,
    required this.openingHours,
  });

  final List<String> openingHours;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PlaceDetailsSectionTitle(title: 'Godziny otwarcia'),
        ...openingHours.map((hours) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                hours,
                style: AppTextStyles.bodySmall,
              ),
            )),
      ],
    );
  }
}
