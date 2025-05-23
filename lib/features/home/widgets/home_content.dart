import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  @override
  Widget build(BuildContext context) {
    const colorizeColors = [
      Colors.green,
      Colors.blue,
      Colors.yellow,
      Colors.red,
    ];

    const colorizeTextStyle = TextStyle(
      fontSize: 30,
      fontFamily: 'Horizon',
      fontWeight: FontWeight.bold,
    );

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: Center(
            child: AnimatedTextKit(
              animatedTexts: [
                ColorizeAnimatedText(
                  'Witaj ponownie username!',
                  colors: colorizeColors,
                  textStyle: colorizeTextStyle,
                ),
              ],
              isRepeatingAnimation: true,
              repeatForever: true,
            ),
          ),
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
