import 'package:flutter/material.dart';
import 'package:trip_planner/features/trip/widgets/trip_sorting_helper.dart';

class TripToolbar extends StatelessWidget {
  const TripToolbar({
    super.key,
    required this.searchController,
    required this.searchQuery,
    required this.selectedSort,
    required this.onSearchChanged,
    required this.onSearchClear,
    required this.onSortPressed,
  });

  final TextEditingController searchController;
  final String searchQuery;
  final SortOption selectedSort;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchClear;
  final VoidCallback onSortPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Szukaj podróży...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: onSearchClear,
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              onChanged: onSearchChanged,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: onSortPressed,
            tooltip: 'Sortuj',
            style: IconButton.styleFrom(
              backgroundColor: Colors.grey.shade100,
              shape: const CircleBorder(),
            ),
          ),
        ],
      ),
    );
  }
}

class SortOptionsBottomSheet extends StatelessWidget {
  const SortOptionsBottomSheet({
    super.key,
    required this.selectedSort,
    required this.onSortSelected,
  });

  final SortOption selectedSort;
  final ValueChanged<SortOption> onSortSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Sortuj według',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(height: 20),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: SortOption.values.map((option) {
                return ListTile(
                  leading: Icon(TripSortingHelper.getSortIcon(option)),
                  title: Text(TripSortingHelper.getSortLabel(option)),
                  trailing: selectedSort == option
                      ? const Icon(Icons.check, color: Colors.blue)
                      : null,
                  onTap: () {
                    onSortSelected(option);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
