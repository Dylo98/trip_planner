import 'dart:io';

import 'package:flutter/material.dart';

import 'package:trip_planner/features/profile/widgets/profile_header/profile_cover_image.dart';

import 'package:trip_planner/features/profile/widgets/profile_header/profile_avatar.dart';

import 'package:trip_planner/features/profile/widgets/profile_header/profile_edit_button.dart';

class ProfileHeader extends StatelessWidget {
  final String? coverImageUrl;

  final String? avatarUrl;

  final File? selectedCoverImage;

  final File? selectedProfileImage;

  final VoidCallback? onCoverImageTap;

  final VoidCallback? onProfileImageTap;

  final bool isUpdating;

  const ProfileHeader({
    super.key,
    this.coverImageUrl,
    this.avatarUrl,
    this.selectedCoverImage,
    this.selectedProfileImage,
    this.onCoverImageTap,
    this.onProfileImageTap,
    this.isUpdating = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ProfileCoverImage(
          coverImageUrl: coverImageUrl,
          selectedCoverImage: selectedCoverImage,
          onTap: onCoverImageTap,
          isUpdating: isUpdating,
        ),
        Positioned(
          top: 10,
          right: 10,
          child: ProfileEditButton(
            icon: Icons.camera_alt,
            onTap: isUpdating ? null : onCoverImageTap,
          ),
        ),
        Positioned(
          bottom: -50,
          left: 20,
          child: Stack(
            children: [
              ProfileAvatar(
                avatarUrl: avatarUrl,
                selectedProfileImage: selectedProfileImage,
                onTap: onProfileImageTap,
                isUpdating: isUpdating,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: ProfileEditButton(
                  icon: Icons.camera_alt,
                  size: 40,
                  onTap: isUpdating ? null : onProfileImageTap,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
