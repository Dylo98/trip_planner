import 'package:flutter/material.dart';
import 'package:trip_planner/core/widgets/bottom_navigation/app_bottom_navigation_bar.dart';

class MyTripsScreen extends StatelessWidget {
  const MyTripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Moje podróże'),
      ),
      body: Center(
        child: Text('Ekran moich podróży'),
      ),
      bottomNavigationBar: AppBottomNavigationBar(),
    );
  }
}
