import 'package:trip_planner/features/trip/model/marker_point_model.dart';
import 'package:trip_planner/features/trip/model/expense_item_model.dart';

class PayerSummary {
  final String payerName;
  final String? payerUserId;
  final double totalAmount;
  final int expenseCount;

  const PayerSummary({
    required this.payerName,
    this.payerUserId,
    required this.totalAmount,
    required this.expenseCount,
  });
}

class BudgetStatistics {
  final double totalExpense;
  final Map<String, double> expensesByLocation;
  final Map<String, List<ExpenseItem>> expenseItemsByLocation;
  final List<PayerSummary> payerSummaries;
  final double averageExpense;
  final double highestExpense;
  final double lowestExpense;

  const BudgetStatistics({
    required this.totalExpense,
    required this.expensesByLocation,
    required this.expenseItemsByLocation,
    required this.payerSummaries,
    required this.averageExpense,
    required this.highestExpense,
    required this.lowestExpense,
  });

  bool get hasExpenses => totalExpense > 0;
  int get locationCount => expensesByLocation.length;
  int get totalExpenseItems =>
      expenseItemsByLocation.values.fold(0, (sum, list) => sum + list.length);
}

class BudgetCalculatorService {
  static BudgetStatistics calculateStatistics(List<MarkerPoint> markers) {
    double totalExpense = 0;
    final expensesByLocation = <String, double>{};
    final expenseItemsByLocation = <String, List<ExpenseItem>>{};
    final payerTotals = <String, double>{};
    final payerUserIds = <String, String?>{};
    final payerExpenseCounts = <String, int>{};

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
      } else if (marker.expense != null && marker.expense! > 0) {
        totalExpense += marker.expense!;
        expensesByLocation[locationName] = marker.expense!;

        final legacyExpense = ExpenseItem(
          id: '${marker.id}_legacy',
          title: 'Wydatek',
          amount: marker.expense!,
          payerName: null,
        );
        expenseItemsByLocation[locationName] = [legacyExpense];

        const unknownPayer = 'Nie określono';
        payerTotals[unknownPayer] =
            (payerTotals[unknownPayer] ?? 0) + marker.expense!;
        payerUserIds[unknownPayer] = null;
        payerExpenseCounts[unknownPayer] =
            (payerExpenseCounts[unknownPayer] ?? 0) + 1;
      }
    }

    if (totalExpense == 0) {
      return const BudgetStatistics(
        totalExpense: 0,
        expensesByLocation: {},
        expenseItemsByLocation: {},
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
    final averageExpense = totalExpense / expensesByLocation.length;
    final highestExpense = expenses.reduce((a, b) => a > b ? a : b);
    final lowestExpense = expenses.reduce((a, b) => a < b ? a : b);

    return BudgetStatistics(
      totalExpense: totalExpense,
      expensesByLocation: expensesByLocation,
      expenseItemsByLocation: expenseItemsByLocation,
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
