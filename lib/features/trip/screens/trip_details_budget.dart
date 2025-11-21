import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/features/trip/controller/watch_trip_provider.dart';
import 'package:trip_planner/features/schedule/controller/day_plan_provider.dart';
import 'package:trip_planner/features/trip/model/trip_expense_item_model.dart';
import 'package:trip_planner/features/trip/services/budget_calculator_service.dart';
import 'package:trip_planner/features/trip/services/trip_service.dart';
import 'package:trip_planner/features/trip/widgets/budget/budget_empty_state.dart';
import 'package:trip_planner/features/trip/widgets/budget/budget_expense_list.dart';
import 'package:trip_planner/features/trip/widgets/budget/budget_statistics_card.dart';
import 'package:trip_planner/features/trip/widgets/budget/budget_summary_card.dart';
import 'package:trip_planner/features/trip/widgets/budget/budget_payers_summary.dart';
import 'package:trip_planner/features/trip/widgets/budget/budget_trip_expenses_list.dart';
import 'package:trip_planner/features/trip/widgets/budget/trip_expense_dialog.dart';

class TripDetailsBudgetScreen extends ConsumerWidget {
  final String tripId;

  const TripDetailsBudgetScreen({super.key, required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripAsync = ref.watch(watchTripProvider(tripId));
    final dayPlansAsync = ref.watch(watchAllDayPlansProvider(tripId));

    return Scaffold(
      body: tripAsync.when(
        data: (trip) {
          return dayPlansAsync.when(
            data: (dayPlans) {
              final statistics = BudgetCalculatorService.calculateStatistics(
                trip.markerPoints,
                tripExpenses: trip.tripExpenses,
                dayPlans: dayPlans,
              );

              final hasAnyExpenses = statistics.hasExpenses ||
                  (trip.tripExpenses != null && trip.tripExpenses!.isNotEmpty);

              if (!hasAnyExpenses) {
                return _buildEmptyStateWithFAB(context, ref);
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
                      if (statistics.tripExpenses.isNotEmpty) ...[
                        BudgetTripExpensesList(
                          tripExpenses: statistics.tripExpenses,
                          onEdit: (expense) =>
                              _editTripExpense(context, ref, expense),
                          onDelete: (expense) =>
                              _deleteTripExpense(ref, expense),
                        ),
                        const SizedBox(height: 24),
                      ],
                      if (statistics.payerSummaries.isNotEmpty)
                        BudgetPayersSummary(
                          payerSummaries: statistics.payerSummaries,
                          totalExpense: statistics.totalExpense,
                        ),
                      const SizedBox(height: 24),
                      if (statistics.expensesByLocation.isNotEmpty)
                        BudgetExpenseList(
                          expensesByLocation: statistics.expensesByLocation,
                          expenseItemsByLocation:
                              statistics.expenseItemsByLocation,
                          totalExpense: statistics.totalExpense,
                        ),
                      if (statistics.expensesByLocation.isNotEmpty)
                        const SizedBox(height: 24),
                      if (statistics.expensesByLocation.isNotEmpty)
                        BudgetStatisticsCard(
                          averageExpense: statistics.averageExpense,
                          highestExpense: statistics.highestExpense,
                          lowestExpense: statistics.lowestExpense,
                        ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) =>
                Center(child: Text('Błąd ładowania harmonogramu: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Błąd: $e')),
      ),
      floatingActionButton: tripAsync.maybeWhen(
        data: (trip) => FloatingActionButton.extended(
          onPressed: () => _addTripExpense(context, ref),
          icon: const Icon(Icons.add),
          label: const Text('Dodaj wydatek'),
          backgroundColor: Colors.green,
        ),
        orElse: () => null,
      ),
    );
  }

  Widget _buildEmptyStateWithFAB(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        const BudgetEmptyState(),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.extended(
            onPressed: () => _addTripExpense(context, ref),
            icon: const Icon(Icons.add),
            label: const Text('Dodaj wydatek'),
            backgroundColor: Colors.green,
          ),
        ),
      ],
    );
  }

  Future<void> _addTripExpense(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<TripExpenseItem>(
      context: context,
      builder: (context) => TripExpenseDialog(tripId: tripId),
    );

    if (result != null) {
      try {
        await ref.read(tripServiceProvider).addTripExpense(
              tripId: tripId,
              expense: result,
            );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Dodano wydatek ogólny'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Błąd: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Future<void> _editTripExpense(
    BuildContext context,
    WidgetRef ref,
    TripExpenseItem expense,
  ) async {
    final result = await showDialog<TripExpenseItem>(
      context: context,
      builder: (context) => TripExpenseDialog(
        tripId: tripId,
        expenseItem: expense,
      ),
    );

    if (result != null) {
      try {
        await ref.read(tripServiceProvider).updateTripExpense(
              tripId: tripId,
              expense: result,
            );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Zaktualizowano wydatek'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Błąd: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteTripExpense(
    WidgetRef ref,
    TripExpenseItem expense,
  ) async {
    try {
      await ref.read(tripServiceProvider).deleteTripExpense(
            tripId: tripId,
            expenseId: expense.id,
          );
    } catch (e) {
//
    }
  }
}
