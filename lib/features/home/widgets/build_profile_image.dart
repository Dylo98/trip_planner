import 'package:flutter/material.dart';

// CONSTANTS //
import 'package:trip_planner/features/home/constants/layout_constants.dart';

// FIREBASE //
import 'package:firebase_auth/firebase_auth.dart';

class BuildProfileImage extends StatelessWidget {
  const BuildProfileImage({super.key});

  @override
  Widget build(BuildContext context) {
    final photoUrl = FirebaseAuth.instance.currentUser?.photoURL;

    return CircleAvatar(
      radius: profileHeight / 2,
      backgroundColor: Colors.white,
      child: CircleAvatar(
        radius: profileHeight / 2 - 10,
        backgroundColor: Colors.grey.shade300,
        backgroundImage: photoUrl != null && photoUrl.isNotEmpty
            ? NetworkImage(photoUrl)
            : null,
        child: photoUrl == null || photoUrl.isEmpty
            ? const Icon(Icons.person, size: 40, color: Colors.white70)
            : null,
      ),
    );
  }
}
