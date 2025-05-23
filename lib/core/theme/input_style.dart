import 'package:flutter/material.dart';
import 'package:trip_planner/core/theme/colors.dart';

class AppInputStyle {
  static InputDecoration inputDecoration({
    required IconData icon,
    required String labelText,
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
          child: Icon(icon, color: Colors.white),
        ),
      ),
      labelText: labelText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(50),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 1,
        ),
      ),
    );
  }
}
