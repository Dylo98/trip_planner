import 'package:flutter/material.dart';

// CONSTANTS //
import 'package:trip_planner/features/home/constants/layout_constants.dart';

class BuildCoverImage extends StatelessWidget {
  const BuildCoverImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Image.asset(
        'assets/images/image_home.jpg',
        height: coverHeight,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }
}
