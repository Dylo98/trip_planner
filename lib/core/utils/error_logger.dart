import 'dart:developer' as developer;

/// Utility dla logowania błędów w aplikacji
class ErrorLogger {
  /// Loguje błąd z kontekstem
  static void log(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String? context,
  }) {
    final logMessage = context != null ? '[$context] $message' : message;

    developer.log(
      logMessage,
      error: error,
      stackTrace: stackTrace,
      name: 'TripPlanner',
    );

    // TODO: W przyszłości można dodać integrację z Firebase Crashlytics
    // lub innym error tracking service
  }

  /// Loguje ostrzeżenie
  static void warn(String message, {String? context}) {
    final logMessage = context != null ? '[$context] $message' : message;
    developer.log(
      logMessage,
      name: 'TripPlanner',
      level: 900, // Warning level
    );
  }

  /// Loguje informację
  static void info(String message, {String? context}) {
    final logMessage = context != null ? '[$context] $message' : message;
    developer.log(
      logMessage,
      name: 'TripPlanner',
      level: 800, // Info level
    );
  }
}
