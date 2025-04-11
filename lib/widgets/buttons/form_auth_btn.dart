import 'package:flutter/material.dart';

// THEME //
import 'package:trip_planner/theme/colors.dart';
import 'package:trip_planner/theme/text_style.dart';
import 'package:trip_planner/theme/button_style.dart';

class FormAuthBtn extends StatelessWidget {
  const FormAuthBtn({
    super.key,
    required this.onPressed,
    required this.text,
  });

  final VoidCallback onPressed;
  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(25),
        ),
        child: ElevatedButton(
          style: AppButtonStyles.primaryButton,
          onPressed: onPressed,
          child: Text(
            text,
            style: AppTextStyles.buttonText,
          ),
        ),
      ),
    );
  }
}
