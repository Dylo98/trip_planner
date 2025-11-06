import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:trip_planner/features/trip/controller/get_trip_provider.dart';
import 'package:trip_planner/features/trip/screens/main_trip_details.dart';

enum SortOption {
  dateNewest,
  dateOldest,
  budgetLowest,
  budgetHighest,
  nameAZ,
  nameZA,
}

class MyTrip extends ConsumerStatefulWidget {
  const MyTrip({super.key});

  @override
  ConsumerState<MyTrip> createState() => _MyTripState();
}

class _MyTripState extends ConsumerState<MyTrip> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  SortOption _selectedSort = SortOption.dateNewest;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  double _calculateTotalBudget(trip) {
    double total = 0;
    for (final marker in trip.markerPoints) {
      if (marker.expense != null) {
        total += marker.expense!;
      }
    }
    return total;
  }

  List _filterAndSortTrips(List trips) {
    var filteredTrips = trips.where((trip) {
      final tripName = trip.name.toLowerCase();
      final query = _searchQuery.toLowerCase();
      return tripName.contains(query);
    }).toList();

    switch (_selectedSort) {
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
          final budgetA = _calculateTotalBudget(a);
          final budgetB = _calculateTotalBudget(b);
          return budgetA.compareTo(budgetB);
        });
        break;
      case SortOption.budgetHighest:
        filteredTrips.sort((a, b) {
          final budgetA = _calculateTotalBudget(a);
          final budgetB = _calculateTotalBudget(b);
          return budgetB.compareTo(budgetA);
        });
        break;
      case SortOption.nameAZ:
        filteredTrips.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortOption.nameZA:
        filteredTrips.sort((a, b) => b.name.compareTo(a.name));
        break;
    }

    return filteredTrips;
  }

  String _getSortLabel(SortOption option) {
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

  IconData _getSortIcon(SortOption option) {
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

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
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
              ...SortOption.values.map((option) {
                return ListTile(
                  leading: Icon(_getSortIcon(option)),
                  title: Text(_getSortLabel(option)),
                  trailing: _selectedSort == option
                      ? const Icon(Icons.check, color: Colors.blue)
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedSort = option;
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tripData = ref.watch(getTripProvider).value ?? [];
    final filteredTrips = _filterAndSortTrips(tripData);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Szukaj podróży...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: IconButton(
                  icon: const Icon(Icons.sort, color: Colors.blue),
                  onPressed: _showSortOptions,
                  tooltip: 'Sortuj',
                ),
              ),
            ],
          ),
        ),

        // Results Info
        if (_searchQuery.isNotEmpty || _selectedSort != SortOption.dateNewest)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                if (_searchQuery.isNotEmpty) ...[
                  Chip(
                    label: Text('Szukaj: "$_searchQuery"'),
                    onDeleted: () {
                      setState(() {
                        _searchController.clear();
                        _searchQuery = '';
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                ],
                if (_selectedSort != SortOption.dateNewest)
                  Chip(
                    avatar: Icon(_getSortIcon(_selectedSort), size: 16),
                    label: Text(_getSortLabel(_selectedSort)),
                    onDeleted: () {
                      setState(() {
                        _selectedSort = SortOption.dateNewest;
                      });
                    },
                  ),
              ],
            ),
          ),

        Expanded(
          child: filteredTrips.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        tripData.isEmpty ? Icons.luggage : Icons.search_off,
                        size: 80,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        tripData.isEmpty
                            ? 'Nie masz jeszcze żadnych podróży'
                            : 'Nie znaleziono podróży',
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
                )
              : ListView.builder(
                  itemCount: filteredTrips.length,
                  itemBuilder: (context, index) {
                    final trip = filteredTrips[index];
                    String urlImage = trip.tripPhotoUrl ?? '';
                    String tripName = trip.name;
                    String formattedStartDate = trip.startDate != null
                        ? DateFormat('dd-MM-yyyy').format(trip.startDate!)
                        : 'Brak daty';
                    final totalBudget = _calculateTotalBudget(trip);

                    return OpenContainer(
                      key: Key('openContainer_${trip.id}'),
                      transitionType: ContainerTransitionType.fadeThrough,
                      closedBuilder: (context, action) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 4.0,
                          ),
                          child: Stack(
                            children: [
                              Card(
                                clipBehavior: Clip.hardEdge,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: SizedBox(
                                  height: 250,
                                  width: double.infinity,
                                  child: urlImage.isNotEmpty &&
                                          Uri.tryParse(urlImage)
                                                  ?.hasAbsolutePath ==
                                              true
                                      ? Image.network(
                                          urlImage,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                        )
                                      : Container(
                                          width: double.infinity,
                                          height: double.infinity,
                                          color: Colors.grey[300],
                                          alignment: Alignment.center,
                                          child: const Text(
                                            'Brak zdjęcia',
                                            style: TextStyle(
                                              color: Colors.black54,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                top: 0,
                                right: 0,
                                left: 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 5,
                                    ),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        tripName,
                                        style: GoogleFonts.bebasNeue().copyWith(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        formattedStartDate,
                                        style: GoogleFonts.bebasNeue().copyWith(
                                          color: const Color(0xFFB9F90B),
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (totalBudget > 0) ...[
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.blue
                                                .withValues(alpha: 0.8),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.account_balance_wallet,
                                                color: Colors.white,
                                                size: 14,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${totalBudget.toStringAsFixed(2)} PLN',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      openBuilder: (context, action) {
                        return MainTripDetailsScreen(
                          key: const Key('tripDetailsScreen'),
                          trip: trip,
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
