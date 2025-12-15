import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:trip_planner/core/theme/button_style.dart';
import 'package:trip_planner/core/theme/text_style.dart';

class HomeEmptyCarousel extends StatelessWidget {
  const HomeEmptyCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Lottie.asset(
          'assets/lottie/LottieAnimation.json',
          width: 200,
          height: 200,
          repeat: true,
        ),
        const SizedBox(height: 16),
        const Text(
          'Nie masz jeszcze żadnych podróży',
          style: AppTextStyles.bodyTextSecondary,
        ),
        const SizedBox(height: 8),
        GradientButton(
          onPressed: () => context.push('/add-trip'),
          child: const Text(
            'Dodaj pierwszą podróż',
            style: AppTextStyles.buttonText,
          ),
        ),
      ],
    );
  }
}
