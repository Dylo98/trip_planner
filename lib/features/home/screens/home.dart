import 'package:flutter/material.dart';

// FIREBASE //
import 'package:firebase_auth/firebase_auth.dart';

// THEME //
import 'package:trip_planner/core/theme/colors.dart';

// WIDGETS //
import 'package:trip_planner/features/home/widgets/home_top.dart';
import 'package:trip_planner/features/home/widgets/home_content.dart';
import 'package:trip_planner/features/home/widgets/add_trip_box.dart';
import 'package:trip_planner/features/home/widgets/home_carousel.dart';

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
      body: ListView(
        children: <Widget>[
          HomeTop(),
          const SizedBox(height: 20),
          HomeContent(),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {},
            child: AddTripBox(),
          ),
          const SizedBox(height: 20),
          HomeCarousel(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '',
          ),
        ],
      ),
    );
  }
}
