import 'package:flutter/material.dart';

class BuildCarouselImage extends StatelessWidget {
  const BuildCarouselImage({super.key, required this.urlImage});

  final String urlImage;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          urlImage,
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      ),
    );
  }
}
