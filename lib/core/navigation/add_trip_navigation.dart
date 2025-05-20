import 'package:flutter/material.dart';
import 'package:trip_planner/features/trip/screens/new_trip.dart';

void navigateToAddTrip(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => const NewTripScreen(),
    ),
  );
}
