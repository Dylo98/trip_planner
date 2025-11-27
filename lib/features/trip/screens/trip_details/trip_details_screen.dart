import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/core/theme/colors.dart';
import 'package:trip_planner/features/trip/model/trip_model.dart';
import 'package:trip_planner/features/trip/screens/trip_details/trip_details_main_screen.dart';
import 'package:trip_planner/features/trip/screens/trip_details/trip_details_map_screen.dart';
import 'package:trip_planner/features/timeline/screens/timeline_screen.dart';
import 'package:trip_planner/features/budget/screens/trip_details_budget_screen.dart';
import 'package:trip_planner/features/schedule/screens/days_schedule_screen.dart';
import 'package:trip_planner/features/trip/services/trip_service.dart';
import 'package:trip_planner/features/friends/widgets/share_trip_dialog.dart';
import 'package:trip_planner/features/friends/widgets/manage_shared_members_dialog.dart';
import 'package:trip_planner/features/friends/controller/friends_provider.dart';
import 'package:trip_planner/features/trip/widgets/shared/delete_trip_dialog.dart';
import 'package:trip_planner/features/trip/providers/watch_trip_provider.dart';

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
      DaysScheduleScreen(
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

  Future<void> _editTripName(String currentName) async {
    final TextEditingController nameController = TextEditingController(
      text: currentName,
    );

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Zmień nazwę podróży'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Nazwa podróży',
            hintText: 'Wpisz nową nazwę',
          ),
          maxLength: 40,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Anuluj'),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = nameController.text.trim();
              if (newName.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Nazwa nie może być pusta'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              if (newName.length < 3) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Nazwa musi mieć min. 3 znaki'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              Navigator.pop(context, newName);
            },
            child: const Text('Zapisz'),
          ),
        ],
      ),
    );

    if (result == null || !mounted) return;

    try {
      await ref
          .read(tripServiceProvider)
          .updateTripName(widget.trip.id, result);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nazwa została zmieniona'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Błąd: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sharedMembersAsync = ref.watch(sharedMembersProvider(widget.trip.id));
    final memberCount = sharedMembersAsync.value?.length ?? 0;

    final tripAsync = ref.watch(watchTripProvider(widget.trip.id));
    final currentTripName = tripAsync.value?.name ?? widget.trip.name;

    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          onTap: () => _editTripName(currentTripName),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    currentTripName,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.edit, size: 18),
              ],
            ),
          ),
        ),
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
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
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
