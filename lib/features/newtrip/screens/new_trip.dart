import 'package:flutter/material.dart';

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
    );
  }
}
