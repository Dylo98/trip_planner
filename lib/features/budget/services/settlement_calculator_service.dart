import 'package:trip_planner/features/budget/model/settlement_transaction_model.dart';
import 'package:trip_planner/features/budget/services/budget_calculator_service.dart';

class SettlementCalculatorService {
  static List<SettlementTransaction> calculateSettlement(
    List<PayerSummary> payerSummaries,
    double totalExpense,
  ) {
    if (payerSummaries.isEmpty || totalExpense == 0) {
      return [];
    }

    final averagePerPerson = totalExpense / payerSummaries.length;

    final balances = payerSummaries.map((payer) {
      return _PersonBalance(
        name: payer.payerName,
        userId: payer.payerUserId,
        balance: payer.totalAmount - averagePerPerson,
      );
    }).toList();

    final creditors = balances.where((b) => b.balance > 0.01).toList()
      ..sort((a, b) => b.balance.compareTo(a.balance));

    final debtors = balances.where((b) => b.balance < -0.01).toList()
      ..sort((a, b) => a.balance.compareTo(b.balance));

    final transactions = <SettlementTransaction>[];

    int creditorIndex = 0;
    int debtorIndex = 0;

    while (creditorIndex < creditors.length && debtorIndex < debtors.length) {
      final creditor = creditors[creditorIndex];
      final debtor = debtors[debtorIndex];

      final amount = _min(creditor.balance, -debtor.balance);

      if (amount > 0.01) {
        transactions.add(
          SettlementTransaction(
            fromPersonName: debtor.name,
            fromPersonUserId: debtor.userId,
            toPersonName: creditor.name,
            toPersonUserId: creditor.userId,
            amount: _roundToTwoDecimals(amount),
          ),
        );

        creditor.balance -= amount;
        debtor.balance += amount;
      }

      if (creditor.balance.abs() < 0.01) creditorIndex++;
      if (debtor.balance.abs() < 0.01) debtorIndex++;
    }

    return transactions;
  }

  static double _min(double a, double b) => a < b ? a : b;

  static double _roundToTwoDecimals(double value) {
    return (value * 100).round() / 100;
  }
}

class _PersonBalance {
  final String name;
  final String? userId;
  double balance;

  _PersonBalance({
    required this.name,
    this.userId,
    required this.balance,
  });
}
