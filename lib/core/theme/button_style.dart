import 'package:flutter/material.dart';
import 'package:trip_planner/core/theme/colors.dart';

class AppButtonStyles {
  static final primaryButton = ElevatedButton.styleFrom(
    backgroundColor: Colors.transparent,
    foregroundColor: Colors.transparent,
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(25),
    ),
  );

  static ButtonStyle gradientButton = ButtonStyle(
    padding: WidgetStateProperty.all(
      const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
    ),
    shape: WidgetStateProperty.all(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    backgroundColor: WidgetStateProperty.all(Colors.transparent),
    shadowColor: WidgetStateProperty.all(Colors.transparent),
    elevation: WidgetStateProperty.all(0),
  );
}

class GradientFAB extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget? icon;
  final Widget? label;

  const GradientFAB({
    super.key,
    required this.onPressed,
    this.icon,
    this.label,
  });

  bool get hasIcon => icon != null;
  bool get hasLabel => label != null;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradientSolid,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: _buildFAB(),
    );
  }

  Widget _buildFAB() {
    if (hasIcon && !hasLabel) {
      return FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: icon,
      );
    }

    if (!hasIcon && hasLabel) {
      return FloatingActionButton.extended(
        onPressed: onPressed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        label: label!,
      );
    }

    return FloatingActionButton.extended(
      onPressed: onPressed,
      backgroundColor: Colors.transparent,
      elevation: 0,
      icon: icon!,
      label: label!,
    );
  }
}

class GradientButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Widget? icon;

  const GradientButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradientSolid,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: AppButtonStyles.gradientButton,
        child: icon == null
            ? child
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  icon!,
                  const SizedBox(width: 8),
                  child,
                ],
              ),
      ),
    );
  }
}
