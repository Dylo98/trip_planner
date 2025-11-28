import 'package:flutter/material.dart';
import 'package:trip_planner/core/theme/colors.dart';
import 'package:trip_planner/core/theme/input_style.dart';
import 'package:trip_planner/core/theme/text_style.dart';
import 'package:trip_planner/features/trip/utils/trip_sorting_helper.dart';

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
              decoration: AppInputStyle.inputDecoration(
                icon: Icons.search,
                labelText: 'Szukaj podróży...',
              ).copyWith(
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: onSearchClear,
                      )
                    : null,
              ),
              onChanged: onSearchChanged,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.sort,
                color: AppColors.white,
              ),
            ),
            onPressed: onSortPressed,
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
            style: AppTextStyles.heading2,
          ),
          const Divider(
            height: 20,
            color: AppColors.divider,
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: SortOption.values.map((option) {
                return ListTile(
                  leading: Icon(
                    TripSortingHelper.getSortIcon(option),
                  ),
                  title: Text(
                    TripSortingHelper.getSortLabel(option),
                  ),
                  trailing: selectedSort == option
                      ? const Icon(
                          Icons.check,
                          color: AppColors.primary,
                        )
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
