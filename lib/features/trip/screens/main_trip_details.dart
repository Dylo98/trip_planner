import 'package:flutter/material.dart';
import 'package:trip_planner/features/trip/model/trip_model.dart';
import 'package:trip_planner/features/trip/screens/trip_details.dart';
import 'package:trip_planner/features/trip/screens/trip_details_map.dart';
import 'package:trip_planner/features/trip/screens/trip_details_timeline.dart';

class MainTripDetailsScreen extends StatefulWidget {
  const MainTripDetailsScreen({super.key, required this.trip});
  final Trip trip;
  @override
  State<MainTripDetailsScreen> createState() => _MainTripDetailsScreenState();
}

class _MainTripDetailsScreenState extends State<MainTripDetailsScreen> {
  int _selectedIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      TripDetailsScreen(trip: widget.trip),
      TripDetailsMapScreen(
        tripId: widget.trip.id,
      ),
      TripDetailsTimelineScreen(
        tripId: widget.trip.id,
      ),
    ];
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.trip.name),
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
            icon: Icon(Icons.dashboard),
            label: 'Podróż',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Mapa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timeline),
            label: 'Podróż',
          ),
        ],
      ),
    );
  }
}
