import 'package:flutter/material.dart';

class AppColors {
  static const background = Colors.white;
  static const primary = Color(0xFF0bda51);
  static const secondary = Color(0xFF7cfc00);
  static const white = Colors.white;
  static const black = Colors.black;
  static const red = Colors.redAccent;
  static const mistyMint = Color(0xFFe4eedd);
  static const lightBlack = Color(0xFF4d4d4d);

  static const limeSlice = Color(0xFFe4ebcb);
  static const limeSliceDark = Color(0xFF797e76);
  static const limeSliceLight = Color(0xFFf2fcee);

  static const grey = Color(0xFF9E9E9E);
  static const lightGrey = Color(0xFFE0E0E0);
  static const darkGrey = Color(0xFF616161);

  static const primaryLight = Color(0xFF3FE577);
  static const primaryDark = Color(0xFF09B043);

  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFFFA726);
  static const error = Color(0xFFEF5350);
  static const info = Color(0xFF29B6F6);

  static const textPrimary = Color(0xFF212121);
  static const textSecondary = Color(0xFF757575);
  static const textHint = Color(0xFFBDBDBD);

  static const surface = Color(0xFF9ACD32);
  static const cardBackground = Colors.white;
  static const divider = Color(0xFFE0E0E0);

  static const borderLight = Color(0xFFEEEEEE);
  static const borderDefault = Color(0xFFE0E0E0);
  static const borderDark = Color(0xFFBDBDBD);
  static const borderPrimary = Color(0xFF0bda51);
  static const borderPrimaryLight = Color(0xFF7cfc00);
  static const borderError = Color(0xFFEF5350);

  static const categoryFood = Color(0xFFFF6B6B);
  static const categoryTransport = Color(0xFF4ECDC4);
  static const categoryAccommodation = Color(0xFF95E1D3);
  static const categoryActivities = Color(0xFFFFE66D);
  static const categoryShopping = Color(0xFFAA96DA);
  static const categoryOther = Color(0xFFB8B8B8);

  static const tripPlanned = Color(0xFF64B5F6);
  static const tripOngoing = Color(0xFF66BB6A);
  static const tripCompleted = Color(0xFF9E9E9E);

  static const roleOwner = Color(0xFFFFB74D);
  static const roleEditor = Color(0xFF81C784);
  static const roleViewer = Color(0xFF90CAF9);

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
