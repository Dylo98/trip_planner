import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trip_planner/core/theme/colors.dart';
import 'package:trip_planner/features/home/constants/layout_constants.dart';
import 'package:trip_planner/features/auth/providers/user_provider.dart';

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
          radius: LayoutConstants.profileHeight / 2,
          backgroundColor: AppColors.white,
          child: CircleAvatar(
            radius: LayoutConstants.profileHeight / 2 - 10,
            backgroundColor: AppColors.limeSliceDark,
            backgroundImage: hasAvatar ? NetworkImage(avatarUrl) : null,
            child: hasAvatar
                ? null
                : Icon(
                    Icons.person,
                    size: LayoutConstants.profileHeight / 2 - 10,
                    color: AppColors.white,
                  ),
          ),
        );
      },
      loading: () => CircleAvatar(
        radius: LayoutConstants.profileHeight / 2,
        backgroundColor: AppColors.white,
        child: CircleAvatar(
          radius: LayoutConstants.profileHeight / 2 - 10,
          backgroundColor: AppColors.white,
          child: const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (_, __) => CircleAvatar(
        radius: LayoutConstants.profileHeight / 2,
        backgroundColor: AppColors.white,
        child: CircleAvatar(
          radius: LayoutConstants.profileHeight / 2 - 10,
          backgroundColor: Colors.grey.shade300,
          child: Icon(
            Icons.person,
            size: LayoutConstants.profileHeight / 2 - 10,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }
}
