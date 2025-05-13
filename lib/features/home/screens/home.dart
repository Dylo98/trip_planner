import 'package:flutter/material.dart';

// FIREBASE //
import 'package:firebase_auth/firebase_auth.dart';

// NAVIGATION //
import 'package:trip_planner/core/navigation/add_trip_navigation.dart';

// THEME //
import 'package:trip_planner/core/theme/colors.dart';
import 'package:trip_planner/core/widgets/bottom_navigation/app_bottom_navigation_bar.dart';
import 'package:trip_planner/core/widgets/drawer/app_drawer.dart';

// WIDGETS //
import 'package:trip_planner/features/home/widgets/home_top.dart';
import 'package:trip_planner/features/home/widgets/home_content.dart';
import 'package:trip_planner/features/home/widgets/add_trip_box.dart';
import 'package:trip_planner/features/home/widgets/home_carousel.dart';
import 'package:trip_planner/features/home/widgets/home_empty_carousel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final List<String> userTrips = [
      // 'https://picsum.photos/200/300?random=1',
      // 'https://picsum.photos/200/300?random=2',
    ];
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
      drawer: AppDrawer(),
      body: ListView(
        children: <Widget>[
          HomeTop(),
          const SizedBox(height: 20),
          HomeContent(),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              navigateToAddTrip(context);
            },
            child: AddTripBox(),
          ),
          const SizedBox(height: 20),
          userTrips.isNotEmpty
              ? HomeCarousel(userTrips: userTrips)
              : HomeEmptyCarousel(),
        ],
      ),
      bottomNavigationBar: AppBottomNavigationBar(),
    );
  }
}
