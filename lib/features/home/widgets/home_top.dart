import 'package:flutter/material.dart';

// WIDGETS //
import 'package:trip_planner/features/home/widgets/build_cover_image.dart';
import 'package:trip_planner/features/home/widgets/build_profile_image.dart';

// CONSTANTS //
import 'package:trip_planner/features/home/constants/layout_constants.dart';

class HomeTop extends StatelessWidget {
  const HomeTop({super.key});

  @override
  Widget build(BuildContext context) {
    final top = coverHeight - profileHeight / 2;
    final bottom = profileHeight / 2;
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          margin: EdgeInsets.only(bottom: bottom),
          child: BuildCoverImage(),
        ),
        Positioned(
          top: top,
          child: BuildProfileImage(),
        ),
      ],
    );
  }
}
