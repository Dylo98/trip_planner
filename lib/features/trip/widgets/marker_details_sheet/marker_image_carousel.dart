import 'package:animations/animations.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class MarkerImageCarousel extends StatelessWidget {
  const MarkerImageCarousel({
    super.key,
    required this.imageUrls,
    required this.currentIndex,
    required this.onPageChanged,
  });

  final List<String> imageUrls;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 300,
            enableInfiniteScroll: false,
            enlargeCenterPage: true,
            viewportFraction: 1,
            onPageChanged: (index, reason) => onPageChanged(index),
          ),
          items: imageUrls.map((url) {
            return GestureDetector(
              onTap: () {
                showGeneralDialog(
                  context: context,
                  barrierDismissible: true,
                  barrierLabel: "Dismiss",
                  barrierColor: Colors.black.withValues(alpha: 0.8),
                  transitionDuration: const Duration(milliseconds: 300),
                  pageBuilder: (_, __, ___) => Center(
                    child: InteractiveViewer(
                      child: Image.network(url, fit: BoxFit.contain),
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
                url,
                fit: BoxFit.cover,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: imageUrls.asMap().entries.map((entry) {
            return Container(
              width: 8.0,
              height: 8.0,
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: currentIndex == entry.key ? Colors.black : Colors.grey,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
