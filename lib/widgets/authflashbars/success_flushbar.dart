import 'package:flutter/material.dart';

// EXTERNAL PACKAGES //
import 'package:another_flushbar/flushbar.dart';

// THEME //
import 'package:trip_planner/theme/colors.dart';

class SuccessFlushbar {
  static void show({
    required BuildContext context,
    required String message,
  }) {
    Flushbar(
      margin: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(12),
      backgroundColor: AppColors.primary,
      message: message,
      duration: const Duration(seconds: 3),
      flushbarPosition: FlushbarPosition.TOP,
      animationDuration: const Duration(milliseconds: 500),
    ).show(context);
  }
}
