import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/features/trip/providers/get_trip_provider.dart';
import 'package:trip_planner/core/utils/action_lock.dart';
import 'package:trip_planner/core/utils/debouncer.dart';
import 'package:trip_planner/features/trip/widgets/trip_sorting_helper.dart';
import 'package:trip_planner/features/trip/widgets/trip_toolbar.dart';
import 'package:trip_planner/features/trip/widgets/trip_card.dart';

class MyTrip extends ConsumerStatefulWidget {
  const MyTrip({super.key});

  @override
  ConsumerState<MyTrip> createState() => _MyTripState();
}

class _MyTripState extends ConsumerState<MyTrip> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  SortOption _selectedSort = SortOption.dateNewest;

  final _searchDebouncer = Debouncer(milliseconds: 350);
  final _openTripLock = ActionLock();

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebouncer.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _searchDebouncer.run(() {
      setState(() => _searchQuery = value);
    });
  }

  void _onSearchClear() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
    });
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SortOptionsBottomSheet(
          selectedSort: _selectedSort,
          onSortSelected: (option) {
            setState(() => _selectedSort = option);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tripData = ref.watch(getTripProvider).value ?? [];
    final filteredTrips = TripSortingHelper.filterAndSort(
      tripData,
      _searchQuery,
      _selectedSort,
    );

    return Column(
      children: [
        TripToolbar(
          searchController: _searchController,
          searchQuery: _searchQuery,
          selectedSort: _selectedSort,
          onSearchChanged: _onSearchChanged,
          onSearchClear: _onSearchClear,
          onSortPressed: _showSortOptions,
        ),
        Expanded(
          child: filteredTrips.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  itemCount: filteredTrips.length,
                  itemBuilder: (context, index) {
                    return TripCard(
                      trip: filteredTrips[index],
                      openTripLock: _openTripLock,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty ? 'Brak podróży' : 'Nie znaleziono podróży',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (_searchQuery.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Spróbuj wyszukać czegoś innego',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ],
      ),
    );
  }
}
