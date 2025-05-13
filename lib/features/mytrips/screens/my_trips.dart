import 'package:flutter/material.dart';

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
    );
  }
}
