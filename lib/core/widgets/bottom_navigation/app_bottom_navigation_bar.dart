import 'package:flutter/material.dart';

// NAVIGATION //
import 'package:trip_planner/core/navigation/home_navigation.dart';

class AppBottomNavigationBar extends StatelessWidget {
  const AppBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
          icon: IconButton(
            onPressed: () {
              navigateToHome(context);
            },
            icon: Icon(Icons.home),
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: IconButton(
            onPressed: () {
              navigateToHome(context);
            },
            icon: Icon(Icons.home),
          ),
          label: '',
        ),
      ],
    );
  }
}
