import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/* PROVIDERS */
import 'package:trip_planner/features/trip/controller/trip_photo_provider.dart';
import 'package:trip_planner/features/trip/controller/trip_markers_provider.dart';
import 'package:trip_planner/features/trip/controller/trip_form_provider.dart';

/* SCREENS */
import 'package:trip_planner/features/trip/screens/new_trip.dart';
import 'package:trip_planner/features/trip/screens/new_trip_map.dart';

class MainNewTripScreen extends ConsumerStatefulWidget {
  const MainNewTripScreen({super.key});

  @override
  ConsumerState<MainNewTripScreen> createState() => _MainNewTripScreenState();
}

class _MainNewTripScreenState extends ConsumerState<MainNewTripScreen> {
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

  void _saveTrip() async {
    final image = ref.read(tripPhotoProvider);
    final markers = ref.read(tripMarkersProvider);

    await ref.read(tripFormProvider.notifier).save(image, markers);

    ref.read(tripMarkersProvider.notifier).clear();
    ref.read(tripPhotoProvider.notifier).state = null;

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nowa podróż'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveTrip,
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
