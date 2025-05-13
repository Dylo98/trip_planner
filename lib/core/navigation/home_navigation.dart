import 'package:flutter/material.dart';
import 'package:trip_planner/features/home/screens/home.dart';

void navigateToHome(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => const HomeScreen(),
    ),
  );
}
