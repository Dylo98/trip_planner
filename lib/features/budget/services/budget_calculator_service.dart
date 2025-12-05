import 'package:trip_planner/features/trip/model/marker_point_model.dart';
import 'package:trip_planner/features/budget/model/expense_item_model.dart';
import 'package:trip_planner/features/schedule/model/day_plan_model.dart';
import 'package:trip_planner/features/friends/model/shared_trip_member_model.dart';
import 'package:trip_planner/features/budget/model/payer_summary_model.dart';
import 'package:trip_planner/features/budget/model/budget_statistics_model.dart';

class BudgetCalculatorService {
  static BudgetStatistics calculateStatistics(
    List<MarkerPoint> markers, {
    List<ExpenseItem>? tripExpenses,
    List<DayPlan>? dayPlans,
    List<SharedTripMember>? sharedMembers,
  }) {
    double totalExpense = 0;
    final expensesByLocation = <String, double>{};
    final expenseItemsByLocation = <String, List<ExpenseItem>>{};
    final payerTotals = <String, double>{};
    final payerUserIds = <String, String?>{};
    final payerExpenseCounts = <String, int>{};

    if (sharedMembers != null && sharedMembers.isNotEmpty) {
      for (final member in sharedMembers) {
        payerTotals[member.displayName] = 0.0;
        payerUserIds[member.displayName] = member.uid;
        payerExpenseCounts[member.displayName] = 0;
      }
    }

    for (final marker in markers) {
      final locationName = marker.name ?? 'Nieznane miejsce';

      if (marker.expenses != null && marker.expenses!.isNotEmpty) {
        double locationTotal = 0;
        final locationExpenses = <ExpenseItem>[];

        for (final expenseItem in marker.expenses!) {
          totalExpense += expenseItem.amount;
          locationTotal += expenseItem.amount;
          locationExpenses.add(expenseItem);

          final payerName = expenseItem.displayPayerName;
          payerTotals[payerName] =
              (payerTotals[payerName] ?? 0) + expenseItem.amount;
          payerUserIds[payerName] = expenseItem.payerUserId;
          payerExpenseCounts[payerName] =
              (payerExpenseCounts[payerName] ?? 0) + 1;
        }

        expensesByLocation[locationName] = locationTotal;
        expenseItemsByLocation[locationName] = locationExpenses;
      }
    }

    if (dayPlans != null && dayPlans.isNotEmpty) {
      for (final dayPlan in dayPlans) {
        for (final item in dayPlan.items) {
          if (item.expenses != null && item.expenses!.isNotEmpty) {
            String? locationName;

            if (item.markerId != null) {
              final marker = markers.firstWhere(
                (m) => m.id == item.markerId,
                orElse: () => null as dynamic,
              );

              locationName = marker.name ?? 'Nieznane miejsce';
            }

            locationName ??= item.title;

            double locationTotal = expensesByLocation[locationName] ?? 0;
            final locationExpenses = List<ExpenseItem>.from(
                expenseItemsByLocation[locationName] ?? []);

            for (final expenseItem in item.expenses!) {
              totalExpense += expenseItem.amount;
              locationTotal += expenseItem.amount;
              locationExpenses.add(expenseItem);

              final payerName = expenseItem.displayPayerName;
              payerTotals[payerName] =
                  (payerTotals[payerName] ?? 0) + expenseItem.amount;
              payerUserIds[payerName] = expenseItem.payerUserId;
              payerExpenseCounts[payerName] =
                  (payerExpenseCounts[payerName] ?? 0) + 1;
            }

            expensesByLocation[locationName] = locationTotal;
            expenseItemsByLocation[locationName] = locationExpenses;
          }
        }
      }
    }

    final processedTripExpenses = <ExpenseItem>[];
    if (tripExpenses != null && tripExpenses.isNotEmpty) {
      for (final expense in tripExpenses) {
        totalExpense += expense.amount;
        processedTripExpenses.add(expense);

        final payerName = expense.displayPayerName;
        payerTotals[payerName] = (payerTotals[payerName] ?? 0) + expense.amount;
        payerUserIds[payerName] = expense.payerUserId;
        payerExpenseCounts[payerName] =
            (payerExpenseCounts[payerName] ?? 0) + 1;
      }
    }

    if (totalExpense == 0 && payerTotals.isEmpty) {
      return const BudgetStatistics(
        totalExpense: 0,
        expensesByLocation: {},
        expenseItemsByLocation: {},
        tripExpenses: [],
        payerSummaries: [],
        averageExpense: 0,
        highestExpense: 0,
        lowestExpense: 0,
      );
    }

    final payerSummaries = payerTotals.entries.map((entry) {
      return PayerSummary(
        payerName: entry.key,
        payerUserId: payerUserIds[entry.key],
        totalAmount: entry.value,
        expenseCount: payerExpenseCounts[entry.key] ?? 0,
      );
    }).toList()
      ..sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

    final expenses = expensesByLocation.values.toList();

    double averageExpense = 0;
    double highestExpense = 0;
    double lowestExpense = 0;

    if (expenses.isNotEmpty) {
      averageExpense = totalExpense / expensesByLocation.length;
      highestExpense = expenses.reduce((a, b) => a > b ? a : b);
      lowestExpense = expenses.reduce((a, b) => a < b ? a : b);
    }

    return BudgetStatistics(
      totalExpense: totalExpense,
      expensesByLocation: expensesByLocation,
      expenseItemsByLocation: expenseItemsByLocation,
      tripExpenses: processedTripExpenses,
      payerSummaries: payerSummaries,
      averageExpense: averageExpense,
      highestExpense: highestExpense,
      lowestExpense: lowestExpense,
    );
  }

  static double calculatePercentage(double expense, double total) {
    if (total == 0) return 0;
    return (expense / total) * 100;
  }

  static double calculatePersonTotal(
    List<MarkerPoint> markers,
    String payerName,
  ) {
    double total = 0;
    for (final marker in markers) {
      if (marker.expenses != null) {
        for (final expense in marker.expenses!) {
          if (expense.displayPayerName == payerName) {
            total += expense.amount;
          }
        }
      }
    }
    return total;
  }

  static Set<String> getAllPayers(List<MarkerPoint> markers) {
    final payers = <String>{};
    for (final marker in markers) {
      if (marker.expenses != null) {
        for (final expense in marker.expenses!) {
          payers.add(expense.displayPayerName);
        }
      }
    }
    return payers;
  }
}
