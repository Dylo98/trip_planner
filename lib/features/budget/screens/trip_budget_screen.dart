import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/core/widgets/error_display.dart';
import 'package:trip_planner/core/widgets/loading_indicator.dart';
import 'package:trip_planner/features/friends/controller/friends_provider.dart';
import 'package:uuid/uuid.dart';

import 'package:trip_planner/core/theme/button_style.dart';
import 'package:trip_planner/core/widgets/app_notifications.dart';
import 'package:trip_planner/features/budget/widgets/budget_empty_state.dart';
import 'package:trip_planner/features/trip/providers/watch_trip_provider.dart';
import 'package:trip_planner/features/schedule/controller/day_plan_provider.dart';
import 'package:trip_planner/features/budget/model/expense_item_model.dart';
import 'package:trip_planner/features/budget/model/budget_payer_selection_model.dart';
import 'package:trip_planner/features/budget/services/budget_calculator_service.dart';
import 'package:trip_planner/features/trip/services/trip_service.dart';
import 'package:trip_planner/features/budget/widgets/summary/budget_location_summary.dart';
import 'package:trip_planner/features/budget/widgets/summary/budget_total_summary.dart';
import 'package:trip_planner/features/budget/widgets/summary/budget_payers_summary.dart';
import 'package:trip_planner/features/budget/widgets/summary/budget_general_summary.dart';
import 'package:trip_planner/features/budget/widgets/dialog/dialog_expense.dart';

class TripBudgetScreen extends ConsumerWidget {
  final String tripId;

  const TripBudgetScreen({super.key, required this.tripId});

  Future<void> _addTripExpense(BuildContext context, WidgetRef ref) async {
    final formResult = await showDialog<ExpenseFormResult>(
      context: context,
      builder: (context) => DialogExpense(
        tripId: tripId,
        isEditMode: false,
      ),
    );

    if (formResult != null) {
      final expense = ExpenseItem(
        id: const Uuid().v4(),
        title: formResult.title,
        amount: formResult.amount,
        payerName: formResult.payer.payerName,
        payerUserId: formResult.payer.payerUserId,
        createdAt: DateTime.now(),
      );

      try {
        await ref.read(tripServiceProvider).addTripExpense(
              tripId: tripId,
              expense: expense,
            );

        if (context.mounted) {
          AppNotifications.showSuccess(
            context: context,
            message: 'Dodano wydatek ogólny',
          );
        }
      } catch (e) {
        if (context.mounted) {
          AppNotifications.showError(
            context: context,
            message: 'Nie udało się dodać wydatku',
          );
        }
      }
    }
  }

  Future<void> _editTripExpense(
    BuildContext context,
    WidgetRef ref,
    ExpenseItem expense,
  ) async {
    final formResult = await showDialog<ExpenseFormResult>(
      context: context,
      builder: (context) => DialogExpense(
        tripId: tripId,
        isEditMode: true,
        initialTitle: expense.title,
        initialAmount: expense.amount,
        initialPayer: BudgetPayerSelection(
          payerName: expense.payerName,
          payerUserId: expense.payerUserId,
        ),
      ),
    );

    if (formResult != null) {
      final updatedExpense = ExpenseItem(
        id: expense.id,
        title: formResult.title,
        amount: formResult.amount,
        payerName: formResult.payer.payerName,
        payerUserId: formResult.payer.payerUserId,
        createdAt: expense.createdAt,
      );

      try {
        await ref.read(tripServiceProvider).updateTripExpense(
              tripId: tripId,
              expense: updatedExpense,
            );

        if (context.mounted) {
          AppNotifications.showSuccess(
            context: context,
            message: 'Zaktualizowano wydatek',
          );
        }
      } catch (e) {
        if (context.mounted) {
          AppNotifications.showError(
            context: context,
            message: 'Nie udało się zaktualizować wydatku',
          );
        }
      }
    }
  }

  Future<void> _deleteTripExpense(
    BuildContext context,
    WidgetRef ref,
    ExpenseItem expense,
  ) async {
    try {
      await ref.read(tripServiceProvider).deleteTripExpense(
            tripId: tripId,
            expenseId: expense.id,
          );

      if (context.mounted) {
        AppNotifications.showSuccess(
          context: context,
          message: 'Usunięto wydatek',
        );
      }
    } catch (e) {
      if (context.mounted) {
        AppNotifications.showError(
          context: context,
          message: 'Nie udało się usunąć wydatku',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripAsync = ref.watch(watchTripProvider(tripId));
    final dayPlansAsync = ref.watch(watchAllDayPlansProvider(tripId));
    final sharedMembersAsync = ref.watch(sharedMembersProvider(tripId));

    return Scaffold(
      body: tripAsync.when(
        data: (trip) {
          return dayPlansAsync.when(
            data: (dayPlans) {
              return sharedMembersAsync.when(
                data: (sharedMembers) {
                  final statistics =
                      BudgetCalculatorService.calculateStatistics(
                    trip.markerPoints,
                    tripExpenses: trip.tripExpenses,
                    dayPlans: dayPlans,
                    sharedMembers: sharedMembers,
                  );

                  final hasAnyExpenses = statistics.hasExpenses ||
                      (trip.tripExpenses != null &&
                          trip.tripExpenses!.isNotEmpty);

                  if (!hasAnyExpenses) {
                    return BudgetEmptyState(
                      onAddPressed: () => _addTripExpense(context, ref),
                    );
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
                                  _deleteTripExpense(context, ref, expense),
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
                loading: () => const LoadingIndicator(
                  message: 'Ładowanie osób współdzielących...',
                ),
                error: (e, _) => ErrorDisplay(
                  message: 'Nie udało się załadować osób współdzielących.',
                  onRetry: () {
                    ref.invalidate(sharedMembersProvider(tripId));
                  },
                ),
              );
            },
            loading: () => const LoadingIndicator(
              message: 'Ładowanie harmonogramu...',
            ),
            error: (e, _) => ErrorDisplay(
              message: 'Nie udało się załadować harmonogramu.',
              onRetry: () => ref.invalidate(watchAllDayPlansProvider(tripId)),
            ),
          );
        },
        loading: () => const LoadingIndicator(
          message: 'Ładowanie danych wycieczki...',
        ),
        error: (e, _) => ErrorDisplay(
          message: 'Nie udało się załadować danych wycieczki.',
          onRetry: () => ref.invalidate(watchTripProvider(tripId)),
        ),
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
}
