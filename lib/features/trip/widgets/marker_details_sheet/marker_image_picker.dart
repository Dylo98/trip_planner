import 'dart:io';
import 'package:flutter/material.dart';
import 'package:trip_planner/core/theme/colors.dart';

class EmptyImagePicker extends StatelessWidget {
  const EmptyImagePicker({
    super.key,
    required this.onTap,
    required this.selectedImage,
  });

  final VoidCallback onTap;
  final File? selectedImage;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 300,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.limeSlice),
          color: Colors.grey[300],
        ),
        child: selectedImage != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  selectedImage!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              )
            : Center(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Icon(Icons.add_a_photo, color: AppColors.white),
                  ),
                ),
              ),
      ),
    );
  }
}
