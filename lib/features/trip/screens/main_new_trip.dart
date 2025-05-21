import 'package:flutter/material.dart';
import 'package:trip_planner/features/trip/screens/new_trip.dart';
import 'package:trip_planner/features/trip/screens/new_trip_map.dart';

class MainNewTripScreen extends StatefulWidget {
  const MainNewTripScreen({super.key});

  @override
  State<MainNewTripScreen> createState() => _MainNewTripScreenState();
}

class _MainNewTripScreenState extends State<MainNewTripScreen> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    const NewTripScreen(),
    const NewTripMapScreen(),
  ];
  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nowa podróż'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              // Handle save action
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabSelected,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Dodaj',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Mapa',
          ),
        ],
      ),
    );
  }
}
