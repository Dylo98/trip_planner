import 'package:trip_planner/features/trip/model/marker_point_model.dart';

class BudgetStatistics {
  final double totalExpense;
  final Map<String, double> expensesByLocation;
  final double averageExpense;
  final double highestExpense;
  final double lowestExpense;

  const BudgetStatistics({
    required this.totalExpense,
    required this.expensesByLocation,
    required this.averageExpense,
    required this.highestExpense,
    required this.lowestExpense,
  });

  bool get hasExpenses => totalExpense > 0;
  int get locationCount => expensesByLocation.length;
}

class BudgetCalculatorService {
  static BudgetStatistics calculateStatistics(List<MarkerPoint> markers) {
    double totalExpense = 0;
    final expensesByLocation = <String, double>{};

    for (final marker in markers) {
      if (marker.expense != null && marker.expense! > 0) {
        totalExpense += marker.expense!;
        final locationName = marker.name ?? 'Nieznane miejsce';
        expensesByLocation[locationName] = marker.expense!;
      }
    }

    if (totalExpense == 0) {
      return const BudgetStatistics(
        totalExpense: 0,
        expensesByLocation: {},
        averageExpense: 0,
        highestExpense: 0,
        lowestExpense: 0,
      );
    }

    final expenses = expensesByLocation.values.toList();
    final averageExpense = totalExpense / expensesByLocation.length;
    final highestExpense = expenses.reduce((a, b) => a > b ? a : b);
    final lowestExpense = expenses.reduce((a, b) => a < b ? a : b);

    return BudgetStatistics(
      totalExpense: totalExpense,
      expensesByLocation: expensesByLocation,
      averageExpense: averageExpense,
      highestExpense: highestExpense,
      lowestExpense: lowestExpense,
    );
  }

  static double calculatePercentage(double expense, double total) {
    if (total == 0) return 0;
    return (expense / total) * 100;
  }
}
