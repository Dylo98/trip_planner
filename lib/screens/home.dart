import 'package:flutter/material.dart';

// FIREBASE //
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trip_planner/theme/colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TripPlanner'),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: Icon(Icons.exit_to_app, color: AppColors.red),
          )
        ],
      ),
      body: const Center(
        child: Text('Zalogowany'),
      ),
    );
  }
}
