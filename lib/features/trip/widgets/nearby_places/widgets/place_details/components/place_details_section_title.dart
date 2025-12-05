import 'package:flutter/material.dart';
import 'package:trip_planner/core/theme/text_style.dart';

class PlaceDetailsSectionTitle extends StatelessWidget {
  const PlaceDetailsSectionTitle({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: AppTextStyles.heading3,
      ),
    );
  }
}
