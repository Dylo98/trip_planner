import 'package:flutter/material.dart';
import 'package:trip_planner/core/theme/colors.dart';

class AppInputStyle {
  static InputDecoration inputDecoration({
    required IconData icon,
    required String labelText,
    String? hintText,
    String? errorText,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      prefixIcon: Container(
        margin: const EdgeInsets.only(left: 12, right: 8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppColors.primaryGradient,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
      labelText: labelText,
      hintText: hintText,
      errorText: errorText,
      labelStyle: const TextStyle(
        color: AppColors.grey,
        fontSize: 14,
      ),
      hintStyle: const TextStyle(
        color: AppColors.grey,
        fontSize: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(50),
        borderSide: const BorderSide(
          color: AppColors.lightGrey,
          width: 1.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(50),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(50),
        borderSide: const BorderSide(
          color: AppColors.red,
          width: 1.5,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(50),
        borderSide: const BorderSide(
          color: AppColors.red,
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 20,
      ),
    );
  }

  static InputDecoration underlineInputDecoration({
    required String labelText,
    String? hintText,
    String? errorText,
  }) {
    return InputDecoration(
      filled: false,
      labelText: labelText,
      hintText: hintText,
      errorText: errorText,
      labelStyle: const TextStyle(color: AppColors.grey, fontSize: 14),
      hintStyle:
          TextStyle(color: AppColors.grey.withValues(alpha: 0.6), fontSize: 14),
      border: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.lightGrey, width: 1),
      ),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.lightGrey, width: 1),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.red, width: 1.5),
      ),
      focusedErrorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.red, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
    );
  }
}
