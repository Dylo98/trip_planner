import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/core/theme/colors.dart';
import 'package:trip_planner/features/statistics/controller/statistics_provider.dart';
import 'package:trip_planner/features/statistics/widgets/statistics_overview.dart';
import 'package:trip_planner/features/statistics/widgets/world_heatmap.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statisticsAsync = ref.watch(statisticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statystyki podróżnika'),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppColors.primaryGradient),
        ),
      ),
      body: statisticsAsync.when(
        data: (statistics) => DefaultTabController(
          length: 2,
          child: Column(
            children: [
              const TabBar(
                labelColor: AppColors.primary,
                unselectedLabelColor: Colors.grey,
                indicatorColor: AppColors.primary,
                tabs: [
                  Tab(text: 'Statystyki', icon: Icon(Icons.bar_chart)),
                  Tab(text: 'Mapa świata', icon: Icon(Icons.map)),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    StatisticsOverview(statistics: statistics),
                    WorldHeatmap(statistics: statistics),
                  ],
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Błąd: $error'),
            ],
          ),
        ),
      ),
    );
  }
}
