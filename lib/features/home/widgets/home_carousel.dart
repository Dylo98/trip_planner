import 'package:flutter/material.dart';

class HomeCarousel extends StatelessWidget {
  const HomeCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 200,
      child: PageView.builder(
        controller: PageController(viewportFraction: 1),
        itemCount: 5,
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              'https://picsum.photos/200/300?random=$index',
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }
}
