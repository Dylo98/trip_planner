import 'dart:io';

import 'package:flutter/material.dart';

import 'package:trip_planner/features/home/constants/layout_constants.dart';

class ProfileAvatar extends StatelessWidget {
  final String? avatarUrl;

  final File? selectedProfileImage;

  final VoidCallback? onTap;

  final bool isUpdating;

  const ProfileAvatar({
    super.key,
    this.avatarUrl,
    this.selectedProfileImage,
    this.onTap,
    this.isUpdating = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasAvatar =
        avatarUrl?.isNotEmpty == true || selectedProfileImage != null;

    return GestureDetector(
      onTap: isUpdating ? null : onTap,
      child: CircleAvatar(
        radius: LayoutConstants.profileHeight / 2,
        backgroundColor: Colors.white,
        child: CircleAvatar(
          radius: LayoutConstants.profileHeight / 2 - 5,
          backgroundColor: Colors.grey.shade300,
          backgroundImage: selectedProfileImage != null
              ? FileImage(selectedProfileImage!)
              : (hasAvatar ? NetworkImage(avatarUrl!) : null) as ImageProvider?,
          child: !hasAvatar
              ? const Icon(Icons.person, size: 50, color: Colors.white70)
              : null,
        ),
      ),
    );
  }
}
