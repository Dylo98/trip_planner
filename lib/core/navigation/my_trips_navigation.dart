import 'package:flutter/material.dart';
import 'package:trip_planner/features/trip/screens/my_trips.dart';

void navigateToMyTrips(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => const MyTripsScreen(),
    ),
  );
}
