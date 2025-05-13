import 'package:flutter/material.dart';

// NAVIGATION //
import 'package:trip_planner/core/navigation/add_trip_navigation.dart';

class AppBottomNavigationBar extends StatelessWidget {
  const AppBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: IconButton(
            onPressed: () {
              navigateToAddTrip(context);
            },
            icon: Icon(Icons.add),
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: '',
        ),
      ],
    );
  }
}
