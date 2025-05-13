import 'package:flutter/material.dart';

// CONSTANTS //
import 'package:trip_planner/features/home/constants/layout_constants.dart';

// FIREBASE //
import 'package:firebase_auth/firebase_auth.dart';

class BuildProfileImage extends StatelessWidget {
  const BuildProfileImage({super.key});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: profileHeight / 2,
      backgroundColor: Colors.white,
      child: CircleAvatar(
        radius: profileHeight / 2 - 10,
        backgroundImage: NetworkImage(
          FirebaseAuth.instance.currentUser?.photoURL ??
              'https://i.pravatar.cc/150?img=5',
        ),
      ),
    );
  }
}
