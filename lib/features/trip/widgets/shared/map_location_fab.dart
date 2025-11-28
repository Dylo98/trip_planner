import 'package:flutter/material.dart';
import 'package:trip_planner/core/theme/colors.dart';

class MapLocationFab extends StatelessWidget {
  const MapLocationFab({
    super.key,
    required this.onPressed,
    required this.isLoading,
  });

  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: isLoading ? null : onPressed,
      elevation: 6,
      backgroundColor: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          shape: BoxShape.circle,
        ),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(
                  Icons.my_location,
                  color: Colors.white,
                ),
        ),
      ),
    );
  }
}
