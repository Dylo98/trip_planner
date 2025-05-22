import 'package:flutter/material.dart';

// FIREBASE //
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// NAVIGATION //
import 'package:trip_planner/core/navigation/add_trip_navigation.dart';
import 'package:trip_planner/core/widgets/drawer/app_drawer.dart';

// THEME //
import 'package:trip_planner/core/theme/colors.dart';

// WIDGETS //
import 'package:trip_planner/features/home/widgets/home_top.dart';
import 'package:trip_planner/features/home/widgets/home_content.dart';
import 'package:trip_planner/features/home/widgets/add_trip_box.dart';
import 'package:trip_planner/features/home/widgets/home_carousel.dart';
import 'package:trip_planner/features/home/widgets/home_empty_carousel.dart';
import 'package:trip_planner/features/trip/controller/get_trip_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final userTripsAsync = ref.watch(getTripProvider);
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
      body: userTripsAsync.when(
        data: (userTrips) => ListView(
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
        error: (err, stack) => Center(child: Text('Błąd: $err')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
