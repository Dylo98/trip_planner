import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

class FullscreenImageScreen extends StatelessWidget {
  const FullscreenImageScreen({super.key, required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onTap: () {
            showGeneralDialog(
              context: context,
              barrierDismissible: true,
              barrierLabel: "Dismiss",
              barrierColor: Colors.black.withValues(alpha: 0.6),
              transitionDuration: const Duration(milliseconds: 300),
              pageBuilder: (_, __, ___) => Center(
                child: InteractiveViewer(
                  child: Image.network(imageUrl, fit: BoxFit.contain),
                ),
              ),
              transitionBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeScaleTransition(
                  animation: animation,
                  child: child,
                );
              },
            );
          },
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
          ),
        ));
  }
}
