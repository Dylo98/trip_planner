import 'package:flutter/material.dart';
import 'package:trip_planner/core/theme/text_style.dart';

class LoadingStateWidget extends StatelessWidget {
  const LoadingStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Szukam ciekawych miejsc...',
              style: AppTextStyles.heading3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'To może chwilę potrwać',
              style: AppTextStyles.bodyTextSecondary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
