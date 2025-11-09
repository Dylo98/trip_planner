import 'package:flutter/material.dart';

class AppColors {
  static const background = Colors.white;
  static const primary = Color(0xFF0bda51);
  static const secondary = Color(0xFF7cfc00);
  static const white = Colors.white;
  static const black = Colors.black;
  static const red = Colors.redAccent;

  static const grey = Color(0xFF9E9E9E);
  static const lightGrey = Color(0xFFE0E0E0);
  static const darkGrey = Color(0xFF616161);

  static final primaryGradient = LinearGradient(
    colors: [
      primary.withValues(alpha: 0.8),
      secondary.withValues(alpha: 0.8),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static final primaryGradientSolid = const LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
