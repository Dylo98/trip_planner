import 'package:flutter/material.dart';
import 'package:trip_planner/features/home/widgets/build_cover_image.dart';
import 'package:trip_planner/features/home/widgets/build_profile_image.dart';
import 'package:trip_planner/features/home/constants/layout_constants.dart';

class HomeTop extends StatelessWidget {
  const HomeTop({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          margin:
              const EdgeInsets.only(bottom: LayoutConstants.coverBottomMargin),
          child: const BuildCoverImage(),
        ),
        const Positioned(
          top: LayoutConstants.profileTop,
          child: BuildProfileImage(),
        ),
      ],
    );
  }
}
