import 'package:flutter/material.dart';
import 'package:trip_planner/features/budget/services/budget_calculator_service.dart';

class BudgetPayersSummary extends StatelessWidget {
  const BudgetPayersSummary({
    super.key,
    required this.payerSummaries,
    required this.totalExpense,
  });

  final List<PayerSummary> payerSummaries;
  final double totalExpense;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      color: Colors.purple.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.people,
                  color: Colors.purple.shade700,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Kto ile zapłacił',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Podsumowanie wydatków według osób',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
              ),
            ),
            const Divider(height: 24),
            ...payerSummaries.map((payer) {
              final percentage = (payer.totalAmount / totalExpense) * 100;
              final isUnknown = payer.payerName == 'Nie określono';

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: isUnknown
                              ? Colors.grey.shade300
                              : Colors.purple.shade100,
                          child: Icon(
                            payer.payerUserId != null
                                ? Icons.person
                                : (isUnknown
                                    ? Icons.help_outline
                                    : Icons.account_circle),
                            color: isUnknown
                                ? Colors.grey.shade600
                                : Colors.purple.shade700,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                payer.payerName,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: isUnknown
                                      ? Colors.grey.shade600
                                      : Colors.black87,
                                  fontStyle: isUnknown
                                      ? FontStyle.italic
                                      : FontStyle.normal,
                                ),
                              ),
                              Text(
                                '${payer.expenseCount} ${_getExpenseWord(payer.expenseCount)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${payer.totalAmount.toStringAsFixed(2)} PLN',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isUnknown
                                    ? Colors.grey.shade700
                                    : Colors.purple.shade700,
                              ),
                            ),
                            Text(
                              '${percentage.toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percentage / 100,
                        minHeight: 8,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isUnknown
                              ? Colors.grey.shade400
                              : Colors.purple.shade400,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            if (payerSummaries.length > 1) ...[
              const Divider(height: 24),
              _buildBalanceInfo(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceInfo() {
    if (payerSummaries.length < 2) return const SizedBox.shrink();

    final averagePerPerson = totalExpense / payerSummaries.length;
    final differences = payerSummaries.map((payer) {
      return payer.totalAmount - averagePerPerson;
    }).toList();

    final maxOverpayment = differences.reduce((a, b) => a > b ? a : b);
    final maxUnderpayment = differences.reduce((a, b) => a < b ? a : b).abs();

    if (maxOverpayment < 1 && maxUnderpayment < 1) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade700, size: 20),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Wydatki są równo rozłożone!',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Rozliczenie',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Średnio na osobę: ${averagePerPerson.toStringAsFixed(2)} PLN',
            style: const TextStyle(fontSize: 13),
          ),
          if (maxOverpayment > 1)
            Text(
              'Największa nadpłata: +${maxOverpayment.toStringAsFixed(2)} PLN',
              style: TextStyle(
                fontSize: 12,
                color: Colors.green.shade700,
              ),
            ),
          if (maxUnderpayment > 1)
            Text(
              'Największe niedopłata: -${maxUnderpayment.toStringAsFixed(2)} PLN',
              style: TextStyle(
                fontSize: 12,
                color: Colors.orange.shade700,
              ),
            ),
        ],
      ),
    );
  }

  String _getExpenseWord(int count) {
    if (count == 1) return 'wydatek';
    if (count % 10 >= 2 &&
        count % 10 <= 4 &&
        (count % 100 < 10 || count % 100 >= 20)) {
      return 'wydatki';
    }
    return 'wydatków';
  }
}
