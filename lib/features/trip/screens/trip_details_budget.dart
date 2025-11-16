import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/features/trip/controller/watch_trip_provider.dart';
import 'package:trip_planner/features/trip/services/budget_calculator_service.dart';
import 'package:trip_planner/features/trip/widgets/budget/budget_empty_state.dart';
import 'package:trip_planner/features/trip/widgets/budget/budget_expense_list.dart';
import 'package:trip_planner/features/trip/widgets/budget/budget_statistics_card.dart';
import 'package:trip_planner/features/trip/widgets/budget/budget_summary_card.dart';
import 'package:trip_planner/features/trip/widgets/budget/budget_payers_summary.dart';

class TripDetailsBudgetScreen extends ConsumerWidget {
  final String tripId;

  const TripDetailsBudgetScreen({super.key, required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripAsync = ref.watch(watchTripProvider(tripId));

    return Scaffold(
      body: tripAsync.when(
        data: (trip) {
          final statistics =
              BudgetCalculatorService.calculateStatistics(trip.markerPoints);

          if (!statistics.hasExpenses) {
            return const BudgetEmptyState();
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BudgetSummaryCard(
                    totalExpense: statistics.totalExpense,
                    locationCount: statistics.locationCount,
                    totalItems: statistics.totalExpenseItems,
                  ),
                  const SizedBox(height: 24),
                  if (statistics.payerSummaries.isNotEmpty)
                    BudgetPayersSummary(
                      payerSummaries: statistics.payerSummaries,
                      totalExpense: statistics.totalExpense,
                    ),
                  const SizedBox(height: 24),
                  BudgetExpenseList(
                    expensesByLocation: statistics.expensesByLocation,
                    expenseItemsByLocation: statistics.expenseItemsByLocation,
                    totalExpense: statistics.totalExpense,
                  ),
                  const SizedBox(height: 24),
                  BudgetStatisticsCard(
                    averageExpense: statistics.averageExpense,
                    highestExpense: statistics.highestExpense,
                    lowestExpense: statistics.lowestExpense,
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Błąd: $e')),
      ),
    );
  }
}
