import 'package:flutter/material.dart';
import 'package:trip_planner/features/trip/model/trip_model.dart';

enum SortOption {
  dateNewest,
  dateOldest,
  budgetLowest,
  budgetHighest,
  nameAZ,
  nameZA,
}

class TripSortingHelper {
  static double calculateTotalBudget(Trip trip) {
    double total = 0;
    for (final marker in trip.markerPoints) {
      if (marker.expense != null) {
        total += marker.expense!;
      }
    }
    return total;
  }

  static List<Trip> filterAndSort(
    List<Trip> trips,
    String searchQuery,
    SortOption sortOption,
  ) {
    final query = searchQuery.trim().toLowerCase();
    final filteredTrips = trips.where((trip) {
      final tripName = (trip.name ?? '').toLowerCase();
      return query.isEmpty ? true : tripName.contains(query);
    }).toList();

    switch (sortOption) {
      case SortOption.dateNewest:
        filteredTrips.sort((a, b) {
          if (a.startDate == null) return 1;
          if (b.startDate == null) return -1;
          return b.startDate!.compareTo(a.startDate!);
        });
        break;
      case SortOption.dateOldest:
        filteredTrips.sort((a, b) {
          if (a.startDate == null) return 1;
          if (b.startDate == null) return -1;
          return a.startDate!.compareTo(b.startDate!);
        });
        break;
      case SortOption.budgetLowest:
        filteredTrips.sort((a, b) {
          final budgetA = calculateTotalBudget(a);
          final budgetB = calculateTotalBudget(b);
          return budgetA.compareTo(budgetB);
        });
        break;
      case SortOption.budgetHighest:
        filteredTrips.sort((a, b) {
          final budgetA = calculateTotalBudget(a);
          final budgetB = calculateTotalBudget(b);
          return budgetB.compareTo(budgetA);
        });
        break;
      case SortOption.nameAZ:
        filteredTrips.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
        break;
      case SortOption.nameZA:
        filteredTrips.sort((a, b) => (b.name ?? '').compareTo(a.name ?? ''));
        break;
    }

    return filteredTrips;
  }

  static String getSortLabel(SortOption option) {
    switch (option) {
      case SortOption.dateNewest:
        return 'Data: Najnowsze';
      case SortOption.dateOldest:
        return 'Data: Najstarsze';
      case SortOption.budgetLowest:
        return 'Budżet: Najniższy';
      case SortOption.budgetHighest:
        return 'Budżet: Najwyższy';
      case SortOption.nameAZ:
        return 'Nazwa: A-Z';
      case SortOption.nameZA:
        return 'Nazwa: Z-A';
    }
  }

  static IconData getSortIcon(SortOption option) {
    switch (option) {
      case SortOption.dateNewest:
      case SortOption.dateOldest:
        return Icons.calendar_today;
      case SortOption.budgetLowest:
      case SortOption.budgetHighest:
        return Icons.attach_money;
      case SortOption.nameAZ:
      case SortOption.nameZA:
        return Icons.sort_by_alpha;
    }
  }
}
