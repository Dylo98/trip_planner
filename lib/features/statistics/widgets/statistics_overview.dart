import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/core/theme/colors.dart';
import 'package:trip_planner/core/theme/text_style.dart';
import 'package:trip_planner/features/statistics/model/traveler_statistics.dart';

class StatisticsOverview extends ConsumerWidget {
  final TravelerStatistics statistics;

  const StatisticsOverview({
    super.key,
    required this.statistics,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countriesCount = statistics.placesByCountry.length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildStatCard(
          'Liczba podróży',
          statistics.totalTrips.toString(),
          Icons.card_travel,
          Colors.blue,
        ),
        _buildExpandableStatCard(
          'Odwiedzone kraje',
          '$countriesCount / 195',
          Icons.flag,
          Colors.green,
          _buildCountriesList(),
        ),
        _buildExpandableStatCard(
          'Wszystkie miejsca',
          statistics.totalPlaces.toString(),
          Icons.place,
          Colors.red,
          _buildAllPlacesList(),
        ),
        _buildStatCard(
          'Przebyta odległość',
          '${statistics.totalDistance.toStringAsFixed(0)} km',
          Icons.route,
          Colors.purple,
        ),
        _buildStatCard(
          'Dni w podróży',
          statistics.totalDays.toString(),
          Icons.calendar_today,
          Colors.teal,
        ),
        _buildStatCard(
          'Łączne wydatki',
          '${statistics.totalExpenses.toStringAsFixed(2)} PLN',
          Icons.attach_money,
          Colors.amber,
        ),
        if (statistics.mostVisitedCountry.isNotEmpty)
          _buildStatCard(
            'Najczęściej odwiedzany kraj',
            statistics.mostVisitedCountry,
            Icons.star,
            Colors.pink,
          ),
        if (statistics.favoriteTransportMode.isNotEmpty)
          _buildStatCard(
            'Ulubiony transport',
            _getTransportName(statistics.favoriteTransportMode),
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
      color: AppColors.limeSlice,
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: AppTextStyles.bodyTextSecondary,
        ),
        subtitle: Text(value, style: AppTextStyles.heading3),
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
      color: AppColors.limeSlice,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: AppTextStyles.bodyTextSecondary,
        ),
        subtitle: Text(value, style: AppTextStyles.heading3),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: expandedContent,
          ),
        ],
      ),
    );
  }

  Widget _buildCountriesList() {
    final countriesData = <String, int>{};

    for (final entry in statistics.placesByCountry.entries) {
      final country = entry.key;
      final places = entry.value;
      countriesData[country] = places.length;
    }

    final sortedCountries = countriesData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sortedCountries.map((entry) {
        final country = entry.key;
        final placesCount = entry.value;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  country,
                  style: AppTextStyles.bodyText,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.limeSliceDark.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$placesCount ${placesCount == 1 ? 'miejsce' : 'miejsc'}',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.limeSliceDark),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAllPlacesList() {
    final allPlaces = <String>[];
    for (final entry in statistics.placesByCountry.entries) {
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
              const Icon(Icons.place, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  place,
                  style: AppTextStyles.bodySmall,
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
