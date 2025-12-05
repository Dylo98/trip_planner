import 'package:trip_planner/features/budget/model/expense_item_model.dart';
import 'package:trip_planner/features/budget/model/payer_summary_model.dart';

class BudgetStatistics {
  final double totalExpense;
  final Map<String, double> expensesByLocation;
  final Map<String, List<ExpenseItem>> expenseItemsByLocation;
  final List<ExpenseItem> tripExpenses;
  final List<PayerSummary> payerSummaries;
  final double averageExpense;
  final double highestExpense;
  final double lowestExpense;

  const BudgetStatistics({
    required this.totalExpense,
    required this.expensesByLocation,
    required this.expenseItemsByLocation,
    required this.tripExpenses,
    required this.payerSummaries,
    required this.averageExpense,
    required this.highestExpense,
    required this.lowestExpense,
  });

  bool get hasExpenses => totalExpense > 0;
  int get locationCount => expensesByLocation.length;
  int get totalExpenseItems =>
      expenseItemsByLocation.values.fold(0, (sum, list) => sum + list.length);
  int get payersCount => payerSummaries.length;
  bool get hasMultiplePayers => payerSummaries.length > 1;
  bool get needsSettlement => hasMultiplePayers && totalExpense > 0;

  PayerSummary? get topPayer =>
      payerSummaries.isEmpty ? null : payerSummaries.first;

  factory BudgetStatistics.empty() {
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

  BudgetStatistics copyWith({
    double? totalExpense,
    Map<String, double>? expensesByLocation,
    Map<String, List<ExpenseItem>>? expenseItemsByLocation,
    List<ExpenseItem>? tripExpenses,
    List<PayerSummary>? payerSummaries,
    double? averageExpense,
    double? highestExpense,
    double? lowestExpense,
  }) {
    return BudgetStatistics(
      totalExpense: totalExpense ?? this.totalExpense,
      expensesByLocation: expensesByLocation ?? this.expensesByLocation,
      expenseItemsByLocation:
          expenseItemsByLocation ?? this.expenseItemsByLocation,
      tripExpenses: tripExpenses ?? this.tripExpenses,
      payerSummaries: payerSummaries ?? this.payerSummaries,
      averageExpense: averageExpense ?? this.averageExpense,
      highestExpense: highestExpense ?? this.highestExpense,
      lowestExpense: lowestExpense ?? this.lowestExpense,
    );
  }

  @override
  String toString() {
    return 'BudgetStatistics(totalExpense: $totalExpense, locations: $locationCount, payers: $payersCount)';
  }
}
