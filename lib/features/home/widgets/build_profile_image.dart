import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

// CONSTANTS
import 'package:trip_planner/features/home/constants/layout_constants.dart';

// PROVIDERS
import 'package:trip_planner/features/auth/controller/user_provider.dart';

class BuildProfileImage extends ConsumerWidget {
  const BuildProfileImage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authUser = FirebaseAuth.instance.currentUser;
    final meAsync = ref.watch(meProvider);

    return meAsync.when(
      data: (me) {
        final avatarUrl = (me?.avatar?.isNotEmpty == true)
            ? me!.avatar!
            : (authUser?.photoURL ?? '');

        final hasAvatar = avatarUrl.isNotEmpty;

        return CircleAvatar(
          radius: profileHeight / 2,
          backgroundColor: Colors.white,
          child: CircleAvatar(
            radius: profileHeight / 2 - 10,
            backgroundColor: Colors.grey.shade300,
            backgroundImage: hasAvatar ? NetworkImage(avatarUrl) : null,
            child: hasAvatar
                ? null
                : Icon(
                    Icons.person,
                    size: profileHeight / 2 - 10,
                    color: Colors.white70,
                  ),
          ),
        );
      },
      loading: () => CircleAvatar(
        radius: profileHeight / 2,
        backgroundColor: Colors.white,
        child: CircleAvatar(
          radius: profileHeight / 2 - 10,
          backgroundColor: Colors.grey.shade300,
          child: const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (_, __) => CircleAvatar(
        radius: profileHeight / 2,
        backgroundColor: Colors.white,
        child: CircleAvatar(
          radius: profileHeight / 2 - 10,
          backgroundColor: Colors.grey.shade300,
          child: Icon(
            Icons.person,
            size: profileHeight / 2 - 10,
            color: Colors.white70,
          ),
        ),
      ),
    );
  }
}
