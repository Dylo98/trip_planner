import 'package:flutter/material.dart';

/* WIDGETS */
import 'package:trip_planner/features/trip/widgets/trip_form.dart';

class NewTripScreen extends StatelessWidget {
  const NewTripScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              TripForm(),
            ],
          ),
        ),
      ),
    );
  }
}
