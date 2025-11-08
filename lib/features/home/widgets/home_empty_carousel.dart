import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// EXTERNAL PACKAGES //
import 'package:lottie/lottie.dart';

// THEME //
import 'package:trip_planner/core/theme/button_style.dart';
import 'package:trip_planner/core/theme/colors.dart';
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
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(25),
          ),
          child: ElevatedButton(
            style: AppButtonStyles.primaryButton,
            onPressed: () => context.push('/add-trip'),
            child: const Text('Dodaj pierwszą podróż',
                style: AppTextStyles.buttonText),
          ),
        ),
      ],
    );
  }
}
