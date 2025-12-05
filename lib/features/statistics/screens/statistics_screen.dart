import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/core/theme/colors.dart';
import 'package:trip_planner/features/statistics/controller/statistics_provider.dart';
import 'package:trip_planner/features/statistics/widgets/statistics_overview.dart';
import 'package:trip_planner/features/statistics/widgets/world_heatmap.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  int _selectedIndex = 0;

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final statistics = ref.watch(statisticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statystyki podróżnika'),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppColors.primaryGradient),
        ),
      ),
      body: _selectedIndex == 0
          ? StatisticsOverview(statistics: statistics)
          : WorldHeatmap(statistics: statistics),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabSelected,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Statystyki',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Mapa',
          ),
        ],
      ),
    );
  }
}
