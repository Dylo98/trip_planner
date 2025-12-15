import 'package:flutter/material.dart';

/// Utility dla zarządzania dialogami w aplikacji
class DialogUtils {
  /// Pokazuje loading dialog (niemodalny spinner)
  static void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  /// Ukrywa aktualnie wyświetlany dialog
  static void hideDialog(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  /// Wykonuje operację asynchroniczną z loading dialogiem
  ///
  /// Pokazuje loading dialog przed wykonaniem operacji i automatycznie
  /// ukrywa go po zakończeniu. Obsługuje również sprawdzanie czy context
  /// jest nadal zamontowany.
  ///
  /// Zwraca wynik operacji lub null jeśli context został odmontowany.
  static Future<T?> executeWithLoading<T>(
    BuildContext context,
    Future<T> Function() operation,
  ) async {
    showLoadingDialog(context);

    try {
      final result = await operation();

      if (context.mounted) {
        hideDialog(context);
        return result;
      }

      return null;
    } catch (e) {
      if (context.mounted) {
        hideDialog(context);
      }
      rethrow;
    }
  }
}
