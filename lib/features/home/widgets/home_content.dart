import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:trip_planner/features/auth/controller/user_provider.dart';

class HomeContent extends ConsumerWidget {
  const HomeContent({super.key});

  String _deriveName(User? user) {
    if (user?.displayName != null && user!.displayName!.trim().isNotEmpty) {
      return user.displayName!.trim();
    }
    final email = user?.email;
    if (email != null && email.contains('@')) {
      return email.split('@').first;
    }
    return 'Użytkowniku';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authUser = FirebaseAuth.instance.currentUser;
    final meAsync = ref.watch(meProvider);

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

    final username = meAsync.when(
      data: (me) {
        if (me?.name?.isNotEmpty == true) {
          return me!.name!;
        }
        return _deriveName(authUser);
      },
      loading: () => 'Użytkowniku',
      error: (_, __) => 'Użytkowniku',
    );

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: Center(
            child: AnimatedTextKit(
              key: ValueKey(username),
              animatedTexts: [
                ColorizeAnimatedText(
                  'Witaj ponownie $username!',
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
