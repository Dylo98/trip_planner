import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/features/trip/model/trip_model.dart';
import 'package:trip_planner/features/trip/screens/trip_details.dart';
import 'package:trip_planner/features/trip/screens/trip_details_map.dart';
import 'package:trip_planner/features/timeline/screens/timeline_screen.dart';
import 'package:trip_planner/features/budget/screens/trip_details_budget_screen.dart';
import 'package:trip_planner/features/schedule/widgets/trip_details_day_plan.dart';
import 'package:trip_planner/features/trip/services/trip_service.dart';
import 'package:trip_planner/features/friends/widgets/share_trip_dialog.dart';
import 'package:trip_planner/features/friends/widgets/manage_shared_members_dialog.dart';
import 'package:trip_planner/features/friends/controller/friends_provider.dart';
import 'package:trip_planner/features/trip/widgets/delete_trip_dialog.dart';

class MainTripDetailsScreen extends ConsumerStatefulWidget {
  const MainTripDetailsScreen({super.key, required this.trip});
  final Trip trip;

  @override
  ConsumerState<MainTripDetailsScreen> createState() =>
      _MainTripDetailsScreenState();
}

class _MainTripDetailsScreenState extends ConsumerState<MainTripDetailsScreen> {
  late final List<Widget> _screens;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _screens = [
      TripDetailsScreen(trip: widget.trip),
      TripDetailsMapScreen(
        tripId: widget.trip.id,
      ),
      TimelineScreen(
        tripId: widget.trip.id,
      ),
      TripDetailsDayPlanScreen(
        tripId: widget.trip.id,
      ),
      TripDetailsBudgetScreen(
        tripId: widget.trip.id,
      ),
    ];
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _deleteTrip() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => DeleteTripDialog(
        tripName: widget.trip.name,
      ),
    );

    if (confirmed != true) return;

    try {
      await ref.read(tripServiceProvider).deleteTrip(widget.trip.id);

      if (mounted) {
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Usunięto podróż "${widget.trip.name}"'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Błąd usuwania: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showShareDialog() {
    showDialog(
      context: context,
      builder: (context) => ShareTripDialog(
        tripId: widget.trip.id,
        tripName: widget.trip.name,
      ),
    );
  }

  void _showManageMembersDialog() {
    showDialog(
      context: context,
      builder: (context) => ManageSharedMembersDialog(
        tripId: widget.trip.id,
        tripName: widget.trip.name,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sharedMembersAsync = ref.watch(sharedMembersProvider(widget.trip.id));
    final memberCount = sharedMembersAsync.value?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.trip.name),
        actions: [
          if (memberCount > 0)
            IconButton(
              icon: Badge(
                label: Text('$memberCount'),
                child: const Icon(Icons.people),
              ),
              tooltip: 'Zarządzaj współwłaścicielami',
              onPressed: _showManageMembersDialog,
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'share') {
                _showShareDialog();
              } else if (value == 'manage_members') {
                _showManageMembersDialog();
              } else if (value == 'delete') {
                _deleteTrip();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Udostępnij podróż'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'manage_members',
                child: Row(
                  children: [
                    Icon(Icons.people, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Zarządzaj dostępem'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text(
                      'Usuń podróż',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
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
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 12,
        unselectedFontSize: 11,
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
            label: 'Oś czasu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Plan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Budżet',
          ),
        ],
      ),
    );
  }
}
