import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/core/theme/button_style.dart';
import 'package:trip_planner/features/trip/providers/watch_trip_provider.dart';
import 'package:trip_planner/features/schedule/controller/day_plan_provider.dart';
import 'package:trip_planner/features/budget/model/trip_expense_item_model.dart';
import 'package:trip_planner/features/budget/services/budget_calculator_service.dart';
import 'package:trip_planner/features/trip/services/trip_service.dart';
import 'package:trip_planner/features/budget/widgets/budget_empty_state.dart';
import 'package:trip_planner/features/budget/widgets/summary/budget_location_summary.dart';
import 'package:trip_planner/features/budget/widgets/summary/budget_total_summary.dart';
import 'package:trip_planner/features/budget/widgets/summary/budget_payers_summary.dart';
import 'package:trip_planner/features/budget/widgets/summary/budget_general_summary.dart';
import 'package:trip_planner/features/budget/widgets/dialog/dialog_trip_expense.dart';

class TripBudgetScreen extends ConsumerWidget {
  final String tripId;

  const TripBudgetScreen({super.key, required this.tripId});

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
                      BudgetTotalSummary(
                        totalExpense: statistics.totalExpense,
                      ),
                      const SizedBox(height: 24),
                      if (statistics.tripExpenses.isNotEmpty) ...[
                        BudgetGeneralSummary(
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
                        BudgetLocationSummary(
                          expensesByLocation: statistics.expensesByLocation,
                          expenseItemsByLocation:
                              statistics.expenseItemsByLocation,
                          totalExpense: statistics.totalExpense,
                        ),
                      if (statistics.expensesByLocation.isNotEmpty)
                        const SizedBox(height: 24),
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
        data: (trip) => GradientFAB(
          onPressed: () => _addTripExpense(context, ref),
          icon: const Icon(Icons.add),
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
          child: GradientFAB(
            onPressed: () => _addTripExpense(context, ref),
            icon: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  Future<void> _addTripExpense(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<TripExpenseItem>(
      context: context,
      builder: (context) => DialogTripExpense(tripId: tripId),
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
      builder: (context) => DialogTripExpense(
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
