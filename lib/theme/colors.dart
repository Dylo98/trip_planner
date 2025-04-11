import 'package:flutter/material.dart';

class AppColors {
  static const background = Colors.white;
  static const primary = Color(0xFF0bda51);
  static const secondary = Color(0xFF7cfc00);
  static const white = Colors.white;
  static const black = Colors.black;
  static const red = Colors.redAccent;

  static final primaryGradient = LinearGradient(
    colors: [
      Color(0xFF0bda51).withValues(alpha: 0.8),
      Color(0xFF7cfc00).withValues(alpha: 0.8),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
