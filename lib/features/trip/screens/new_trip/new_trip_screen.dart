import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/features/trip/providers/trip_photo_provider.dart';
import 'package:trip_planner/features/trip/providers/trip_markers_provider.dart';
import 'package:trip_planner/features/trip/providers/trip_form_provider.dart';
import 'package:trip_planner/features/trip/screens/new_trip/new_trip_map_screen.dart';
import 'package:trip_planner/features/trip/services/trip/trip_form_service.dart';
import 'package:trip_planner/features/trip/widgets/new_trip/trip_form.dart';

class NewTripScreen extends ConsumerStatefulWidget {
  const NewTripScreen({super.key});

  @override
  ConsumerState<NewTripScreen> createState() => _NewTripScreenState();
}

class _NewTripScreenState extends ConsumerState<NewTripScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  int _selectedIndex = 0;
  bool _isSaving = false;

  void _onTabSelected(int index) {
    if (_isSaving) return;
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _saveTrip() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      await TripFormService(ref: ref, context: context).saveTrip(_formKey);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          ref.invalidate(tripFormProvider);
          ref.invalidate(tripPhotoProvider);
          ref.read(tripMarkersProvider.notifier).clear();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Nowa podróż'),
          actions: [
            if (_isSaving)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              IconButton(
                icon: const Icon(Icons.check),
                onPressed: _saveTrip,
              ),
          ],
        ),
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            _NewTripFormTab(formKey: _formKey),
            const NewTripMapScreen(),
          ],
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
      ),
    );
  }
}

class _NewTripFormTab extends StatelessWidget {
  const _NewTripFormTab({required this.formKey});

  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              TripForm(formKey: formKey),
            ],
          ),
        ),
      ),
    );
  }
}
