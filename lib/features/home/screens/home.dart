import 'package:flutter/material.dart';

// FIREBASE //
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// NAVIGATION //
import 'package:trip_planner/core/widgets/drawer/app_drawer.dart';

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
      ),
      drawer: const AppDrawer(),
      body: userTripsAsync.when(
        data: (userTrips) => ListView(
          children: <Widget>[
            HomeTop(),
            const SizedBox(height: 20),
            HomeContent(),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => context.push('/add-trip'),
              child: AddTripBox(),
            ),
            const SizedBox(height: 20),
            userTrips.isNotEmpty
                ? HomeCarousel(userTrips: userTrips.take(3).toList())
                : HomeEmptyCarousel(),
          ],
        ),
        error: (err, stack) => Center(child: Text('Błąd: $err')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
