import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/features/statistics/model/traveler_statistics.dart';
import 'package:trip_planner/features/statistics/controller/cities_loader_provider.dart';
import 'package:trip_planner/features/trip/providers/get_trip_provider.dart';

class StatisticsOverview extends ConsumerStatefulWidget {
  final TravelerStatistics statistics;

  const StatisticsOverview({
    super.key,
    required this.statistics,
  });

  @override
  ConsumerState<StatisticsOverview> createState() => _StatisticsOverviewState();
}

class _StatisticsOverviewState extends ConsumerState<StatisticsOverview> {
  final ScrollController _citiesScrollController = ScrollController();
  bool _citiesExpanded = false;

  @override
  void dispose() {
    _citiesScrollController.dispose();
    super.dispose();
  }

  void _onCitiesExpanded(bool expanded) {
    setState(() {
      _citiesExpanded = expanded;
    });

    if (expanded) {
      final trips = ref.read(getTripProvider).value ?? [];
      final allMarkers = trips.expand((trip) => trip.markerPoints).toList();

      ref.read(citiesLoaderProvider.notifier).loadCities(allMarkers);

      _citiesScrollController.addListener(() {
        if (_citiesScrollController.position.pixels >=
            _citiesScrollController.position.maxScrollExtent * 0.8) {
          ref.read(citiesLoaderProvider.notifier).loadCities(allMarkers);
        }
      });
    }
  }

  Map<String, int> _getCountriesVisitCount() {
    final citiesState = ref.watch(citiesLoaderProvider);
    final countriesVisitCount = <String, int>{};

    for (final entry in citiesState.citiesByCountry.entries) {
      countriesVisitCount[entry.key] = entry.value.length;
    }

    if (countriesVisitCount.isEmpty) {
      for (final country in widget.statistics.placesByCountry.keys) {
        countriesVisitCount[country] = 0;
      }
    }

    return countriesVisitCount;
  }

  @override
  Widget build(BuildContext context) {
    final citiesState = ref.watch(citiesLoaderProvider);
    final totalCities = citiesState.citiesByCountry.values
        .fold<int>(0, (sum, cities) => sum + cities.length);
    final countriesVisitCount = _getCountriesVisitCount();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildStatCard(
          'Liczba podróży',
          widget.statistics.totalTrips.toString(),
          Icons.card_travel,
          Colors.blue,
        ),
        _buildExpandableStatCard(
          'Odwiedzone kraje',
          '${countriesVisitCount.length} / 195',
          Icons.flag,
          Colors.green,
          _buildCountriesList(countriesVisitCount),
        ),
        _buildCitiesCard(totalCities, citiesState),
        _buildExpandableStatCard(
          'Wszystkie miejsca',
          widget.statistics.totalPlaces.toString(),
          Icons.place,
          Colors.red,
          _buildAllPlacesList(),
        ),
        _buildStatCard(
          'Przebyta odległość',
          '${widget.statistics.totalDistance.toStringAsFixed(0)} km',
          Icons.route,
          Colors.purple,
        ),
        _buildStatCard(
          'Dni w podróży',
          widget.statistics.totalDays.toString(),
          Icons.calendar_today,
          Colors.teal,
        ),
        _buildStatCard(
          'Łączne wydatki',
          '${widget.statistics.totalExpenses.toStringAsFixed(2)} PLN',
          Icons.attach_money,
          Colors.amber,
        ),
        if (widget.statistics.mostVisitedCountry.isNotEmpty)
          _buildStatCard(
            'Najczęściej odwiedzany kraj',
            widget.statistics.mostVisitedCountry,
            Icons.star,
            Colors.pink,
          ),
        if (widget.statistics.favoriteTransportMode.isNotEmpty)
          _buildStatCard(
            'Ulubiony transport',
            _getTransportName(widget.statistics.favoriteTransportMode),
            Icons.directions,
            Colors.indigo,
          ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    Widget expandedContent,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: expandedContent,
          ),
        ],
      ),
    );
  }

  Widget _buildCitiesCard(int totalCities, CitiesLoaderState citiesState) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ExpansionTile(
        onExpansionChanged: _onCitiesExpanded,
        leading: CircleAvatar(
          backgroundColor: Colors.orange.withValues(alpha: 0.2),
          child: const Icon(Icons.location_city, color: Colors.orange),
        ),
        title: const Text(
          'Odwiedzone miasta',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        subtitle: Text(
          totalCities.toString(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildCitiesList(citiesState),
          ),
        ],
      ),
    );
  }

  Widget _buildCountriesList(Map<String, int> countriesVisitCount) {
    final countries = countriesVisitCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: countries.map((entry) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  entry.key,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  entry.value > 0
                      ? '${entry.value} ${entry.value == 1 ? 'miasto' : 'miast'}'
                      : 'Ładowanie...',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCitiesList(CitiesLoaderState citiesState) {
    final allCities = <String>[];
    for (final entry in citiesState.citiesByCountry.entries) {
      for (final city in entry.value) {
        allCities.add('${city.cityName}, ${entry.key}');
      }
    }
    allCities.sort();

    return SizedBox(
      height: 300,
      child: ListView.builder(
        controller: _citiesScrollController,
        itemCount: allCities.length + (citiesState.isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == allCities.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.location_city, size: 20, color: Colors.orange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    allCities[index],
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAllPlacesList() {
    final allPlaces = <String>[];
    for (final entry in widget.statistics.placesByCountry.entries) {
      for (final place in entry.value) {
        allPlaces.add('${place.placeName}, ${entry.key}');
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: allPlaces.map((place) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              const Icon(Icons.place, size: 20, color: Colors.red),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  place,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _getTransportName(String mode) {
    switch (mode) {
      case 'plane':
        return 'Samolot';
      case 'car':
        return 'Samochód';
      case 'walk':
        return 'Pieszo';
      case 'other':
        return 'Inne';
      default:
        return mode;
    }
  }
}
