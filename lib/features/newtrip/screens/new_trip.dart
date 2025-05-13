import 'package:flutter/material.dart';
import 'package:trip_planner/core/widgets/bottom_navigation/app_bottom_navigation_bar.dart';

class NewTripScreen extends StatelessWidget {
  const NewTripScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nowa podróż'),
      ),
      body: Center(
        child: Text('Ekran dodawania nowej podróży'),
      ),
      bottomNavigationBar: AppBottomNavigationBar(),
    );
  }
}
