import 'package:flutter/material.dart';
import 'package:trip_planner/core/theme/text_style.dart';

class DialogConfirmation extends StatelessWidget {
  const DialogConfirmation({
    super.key,
    required this.title,
    required this.content,
    this.confirmText = 'Potwierdź',
    this.cancelText = 'Anuluj',
    this.confirmColor,
    this.isDestructive = false,
    this.icon,
  });

  final String title;
  final String content;
  final String confirmText;
  final String cancelText;
  final Color? confirmColor;
  final bool isDestructive;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final effectiveConfirmColor = confirmColor ??
        (isDestructive ? Colors.red : Theme.of(context).primaryColor);

    return AlertDialog(
      title: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: isDestructive ? Colors.red : null,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.heading2,
            ),
          ),
        ],
      ),
      content: Text(
        content,
        style: AppTextStyles.bodyText,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            cancelText,
            style: AppTextStyles.bodySmallGreen,
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(
            foregroundColor: effectiveConfirmColor,
          ),
          child: Text(confirmText, style: AppTextStyles.bodySmallRed),
        ),
      ],
    );
  }

  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String content,
    String confirmText = 'Potwierdź',
    String cancelText = 'Anuluj',
    Color? confirmColor,
    bool isDestructive = false,
    IconData? icon,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => DialogConfirmation(
        title: title,
        content: content,
        confirmText: confirmText,
        cancelText: cancelText,
        confirmColor: confirmColor,
        isDestructive: isDestructive,
        icon: icon,
      ),
    );
    return result ?? false;
  }
}

class ConfirmationDialogs {
  static Future<bool> delete({
    required BuildContext context,
    required String title,
    required String content,
    String confirmText = 'Usuń',
  }) {
    return DialogConfirmation.show(
      context: context,
      title: title,
      content: content,
      confirmText: confirmText,
      isDestructive: true,
      icon: Icons.delete_outline,
    );
  }

  static Future<bool> removeFriend({
    required BuildContext context,
    required String friendName,
  }) {
    return delete(
      context: context,
      title: 'Usuń znajomego',
      content: 'Czy na pewno chcesz usunąć $friendName z listy znajomych?',
    );
  }

  static Future<bool> deleteTrip({
    required BuildContext context,
    required String tripName,
  }) {
    return delete(
      context: context,
      title: 'Usuń wycieczkę',
      content:
          'Czy na pewno chcesz usunąć wycieczkę "$tripName"? Ta operacja jest nieodwracalna.',
    );
  }

  static Future<bool> deleteExpense({
    required BuildContext context,
    required String expenseName,
  }) {
    return delete(
      context: context,
      title: 'Usuń wydatek',
      content: 'Czy na pewno chcesz usunąć wydatek "$expenseName"?',
    );
  }

  static Future<bool> deletePhoto({
    required BuildContext context,
  }) {
    return delete(
      context: context,
      title: 'Usuń zdjęcie',
      content: 'Czy na pewno chcesz usunąć to zdjęcie?',
    );
  }

  static Future<bool> logout({
    required BuildContext context,
  }) {
    return DialogConfirmation.show(
      context: context,
      title: 'Wyloguj się',
      content: 'Czy na pewno chcesz się wylogować?',
      confirmText: 'Wyloguj',
      icon: Icons.logout,
    );
  }

  static Future<bool> rejectFriendRequest({
    required BuildContext context,
    required String senderName,
  }) {
    return DialogConfirmation.show(
      context: context,
      title: 'Odrzuć zaproszenie',
      content: 'Czy na pewno chcesz odrzucić zaproszenie od $senderName?',
      confirmText: 'Odrzuć',
      isDestructive: true,
    );
  }

  static Future<bool> discardChanges({
    required BuildContext context,
  }) {
    return DialogConfirmation.show(
      context: context,
      title: 'Odrzuć zmiany',
      content: 'Czy na pewno chcesz odrzucić niezapisane zmiany?',
      confirmText: 'Odrzuć',
      isDestructive: true,
      icon: Icons.warning_amber_rounded,
    );
  }

  static Future<bool> warning({
    required BuildContext context,
    required String title,
    required String content,
    String confirmText = 'Kontynuuj',
  }) {
    return DialogConfirmation.show(
      context: context,
      title: title,
      content: content,
      confirmText: confirmText,
      icon: Icons.warning_amber_rounded,
    );
  }

  static Future<void> info({
    required BuildContext context,
    required String title,
    required String content,
    String buttonText = 'OK',
    IconData? icon,
  }) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            if (icon != null) ...[
              Icon(icon),
              const SizedBox(width: 12),
            ],
            Expanded(child: Text(title)),
          ],
        ),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }
}
