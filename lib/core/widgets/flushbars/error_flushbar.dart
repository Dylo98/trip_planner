import 'package:flutter/material.dart';

// EXTERNAL PACKAGES //
import 'package:another_flushbar/flushbar.dart';

// THEME //
import 'package:trip_planner/core/theme/colors.dart';

class ErrorFlushbar {
  static void show({
    required BuildContext context,
    required String message,
  }) {
    Flushbar(
      margin: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(12),
      backgroundColor: AppColors.red,
      message: message,
      duration: const Duration(seconds: 3),
      flushbarPosition: FlushbarPosition.TOP,
      animationDuration: const Duration(milliseconds: 500),
    ).show(context);
  }
}
