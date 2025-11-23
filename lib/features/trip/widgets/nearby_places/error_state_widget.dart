import 'package:flutter/material.dart';

class ErrorStateWidget extends StatelessWidget {
  const ErrorStateWidget({
    super.key,
    required this.error,
    required this.onRetry,
  });

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final errorInfo = _analyzeError(error);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIcon(errorInfo),
            const SizedBox(height: 16),
            _buildTitle(context),
            const SizedBox(height: 8),
            _buildMessage(context, errorInfo),
            if (errorInfo.suggestion != null) ...[
              const SizedBox(height: 12),
              _buildSuggestion(context, errorInfo.suggestion!),
            ],
            const SizedBox(height: 24),
            _buildRetryButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(_ErrorInfo errorInfo) {
    return Icon(
      errorInfo.icon,
      size: 64,
      color: errorInfo.color,
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      'Nie udało się załadować miejsc',
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildMessage(BuildContext context, _ErrorInfo errorInfo) {
    return Text(
      errorInfo.message,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey.shade600,
          ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSuggestion(BuildContext context, String suggestion) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline,
            size: 20,
            color: Colors.blue.shade700,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              suggestion,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.blue.shade900,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRetryButton() {
    return ElevatedButton.icon(
      onPressed: onRetry,
      icon: const Icon(Icons.refresh),
      label: const Text('Spróbuj ponownie'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
      ),
    );
  }

  _ErrorInfo _analyzeError(Object error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('quota') ||
        errorString.contains('limit') ||
        errorString.contains('exceeded')) {
      return _ErrorInfo(
        icon: Icons.block,
        color: Colors.orange.shade300,
        message: 'Przekroczono dzienny limit zapytań do API',
        suggestion:
            'Limit zostanie zresetowany o północy. Spróbuj użyć innej kategorii lub zmniejsz promień wyszukiwania.',
      );
    }

    if (errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('socket')) {
      return _ErrorInfo(
        icon: Icons.wifi_off,
        color: Colors.red.shade300,
        message: 'Problem z połączeniem internetowym',
        suggestion: 'Sprawdź połączenie z internetem i spróbuj ponownie.',
      );
    }

    if (errorString.contains('timeout')) {
      return _ErrorInfo(
        icon: Icons.hourglass_empty,
        color: Colors.orange.shade300,
        message: 'Żądanie przekroczyło limit czasu',
        suggestion: 'Serwer nie odpowiedział na czas. Spróbuj ponownie.',
      );
    }

    if (errorString.contains('api key') ||
        errorString.contains('unauthorized') ||
        errorString.contains('403')) {
      return _ErrorInfo(
        icon: Icons.key_off,
        color: Colors.red.shade300,
        message: 'Problem z kluczem API',
        suggestion: 'Skontaktuj się z administratorem aplikacji.',
      );
    }

    return _ErrorInfo(
      icon: Icons.error_outline,
      color: Colors.red.shade300,
      message: 'Wystąpił nieoczekiwany błąd',
      suggestion: 'Spróbuj ponownie za chwilę.',
    );
  }
}

class _ErrorInfo {
  final IconData icon;
  final Color color;
  final String message;
  final String? suggestion;

  const _ErrorInfo({
    required this.icon,
    required this.color,
    required this.message,
    this.suggestion,
  });
}
