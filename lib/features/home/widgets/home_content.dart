import 'package:flutter/material.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Witaj ponownie username!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        const Text(
          'Zaplanuj swoją podróż i podziel się nią z innymi!',
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
