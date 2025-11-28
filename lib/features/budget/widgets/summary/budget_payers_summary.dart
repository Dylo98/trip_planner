import 'package:flutter/material.dart';
import 'package:trip_planner/core/theme/colors.dart';
import 'package:trip_planner/core/theme/text_style.dart';
import 'package:trip_planner/features/budget/services/budget_calculator_service.dart';
import 'package:trip_planner/features/budget/services/settlement_calculator_service.dart';
import 'package:trip_planner/features/budget/widgets/dialog/dialog_settlement.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(
              Icons.people,
              size: 20,
              color: AppColors.primary,
            ),
            SizedBox(width: 8),
            Text(
              'Kto ile zapłacił',
              style: AppTextStyles.heading3,
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Podsumowanie wydatków według osób',
          style: AppTextStyles.bodyTextSecondary,
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 3,
          color: AppColors.limeSlice,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                              backgroundColor: AppColors.limeSliceDark
                                  .withValues(alpha: 0.1),
                              child: Icon(
                                payer.payerUserId != null
                                    ? Icons.person
                                    : (isUnknown
                                        ? Icons.help_outline
                                        : Icons.account_circle),
                                color: AppColors.limeSliceDark,
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
                                    style: AppTextStyles.bodyText,
                                  ),
                                  Text(
                                    '${payer.expenseCount} ${_getExpenseWord(payer.expenseCount)}',
                                    style: AppTextStyles.bodyTextSecondary,
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${payer.totalAmount.toStringAsFixed(2)} PLN',
                                  style: AppTextStyles.priceTextSmall,
                                ),
                                Text(
                                  '${percentage.toStringAsFixed(1)}%',
                                  style: AppTextStyles.bodyTextSecondary,
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
                            backgroundColor: AppColors.white,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                if (payerSummaries.length > 1) ...[
                  const Divider(height: 24),
                  _buildBalanceInfo(context),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceInfo(BuildContext context) {
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
          color: AppColors.limeSliceLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Expanded(
              child: Center(
                child: Text(
                  'Wydatki są równo rozłożone',
                  style: AppTextStyles.bodyText,
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
        color: AppColors.limeSliceLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.limeSliceDark),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Rozliczenie',
                style: AppTextStyles.heading4,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Średnio na osobę: ${averagePerPerson.toStringAsFixed(2)} PLN',
            style: AppTextStyles.bodySmall,
          ),
          if (maxOverpayment > 1)
            Text(
              'Największa nadpłata: +${maxOverpayment.toStringAsFixed(2)} PLN',
              style: AppTextStyles.bodySmallGreen,
            ),
          if (maxUnderpayment > 1)
            Text(
              'Największa niedopłata: -${maxUnderpayment.toStringAsFixed(2)} PLN',
              style: AppTextStyles.bodySmallRed,
            ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showSettlementDialog(context),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Zobacz szczegóły rozliczenia',
                        style: AppTextStyles.buttonText,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _showSettlementDialog(BuildContext context) {
    final transactions = SettlementCalculatorService.calculateSettlement(
      payerSummaries,
      totalExpense,
    );

    final averagePerPerson = totalExpense / payerSummaries.length;

    showDialog(
      context: context,
      builder: (context) => DialogSettlement(
        transactions: transactions,
        averagePerPerson: averagePerPerson,
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
