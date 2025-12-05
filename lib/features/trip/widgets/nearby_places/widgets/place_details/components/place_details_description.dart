import 'package:flutter/material.dart';
import 'package:trip_planner/features/trip/widgets/nearby_places/widgets/place_details/components/place_details_section_title.dart';

class PlaceDetailsDescription extends StatelessWidget {
  const PlaceDetailsDescription({
    super.key,
    required this.description,
  });

  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PlaceDetailsSectionTitle(title: 'Opis'),
        Text(
          description,
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
      ],
    );
  }
}
