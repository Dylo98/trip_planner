import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

class SuccessFlushbar {
  static void show({
    required BuildContext context,
    required String message,
  }) {
    Flushbar(
      margin: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(12),
      backgroundColor: Colors.lightGreen,
      message: message,
      duration: const Duration(seconds: 3),
      flushbarPosition: FlushbarPosition.TOP,
      animationDuration: const Duration(milliseconds: 500),
    ).show(context);
  }
}
