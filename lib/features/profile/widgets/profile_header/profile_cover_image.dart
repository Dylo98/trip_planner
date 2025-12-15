import 'dart:io';
import 'package:flutter/material.dart';
import 'package:trip_planner/features/home/constants/layout_constants.dart';

class ProfileCoverImage extends StatelessWidget {
  final String? coverImageUrl;

  final File? selectedCoverImage;

  final VoidCallback? onTap;

  final bool isUpdating;

  const ProfileCoverImage({
    super.key,
    this.coverImageUrl,
    this.selectedCoverImage,
    this.onTap,
    this.isUpdating = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isUpdating ? null : onTap,
      child: Container(
        height: LayoutConstants.coverHeight,
        width: double.infinity,
        color: Colors.black,
        child: _buildImage(),
      ),
    );
  }

  Widget _buildImage() {
    if (selectedCoverImage != null) {
      return Image.file(selectedCoverImage!, fit: BoxFit.cover);
    }

    if (coverImageUrl?.isNotEmpty == true) {
      return Image.network(
        coverImageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Image.asset(
          'assets/images/image_home.jpg',
          fit: BoxFit.cover,
        ),
      );
    }

    return Image.asset(
      'assets/images/image_home.jpg',
      fit: BoxFit.cover,
    );
  }
}
