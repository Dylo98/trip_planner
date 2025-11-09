import 'package:flutter/material.dart';
import 'package:trip_planner/core/theme/colors.dart';

class AppNotifications {
  static DateTime? _lastShownAt;
  static String? _lastMessage;
  static const Duration _cooldown = Duration(milliseconds: 600);

  static void _show({
    required BuildContext context,
    required String message,
    required Color backgroundColor,
  }) {
    if (!context.mounted) return;

    final now = DateTime.now();
    if (_lastMessage == message &&
        _lastShownAt != null &&
        now.difference(_lastShownAt!) < _cooldown) {
      return;
    }

    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger.clearSnackBars();

    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );

    _lastMessage = message;
    _lastShownAt = now;
  }

  static void showError({
    required BuildContext context,
    required String message,
  }) {
    _show(context: context, message: message, backgroundColor: AppColors.red);
  }

  static void showSuccess({
    required BuildContext context,
    required String message,
  }) {
    _show(
        context: context, message: message, backgroundColor: AppColors.primary);
  }

  static void showInfo({
    required BuildContext context,
    required String message,
  }) {
    _show(context: context, message: message, backgroundColor: Colors.blue);
  }
}
