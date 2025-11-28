import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trip_planner/core/theme/colors.dart';
import 'package:trip_planner/core/theme/text_style.dart';
import 'package:trip_planner/core/widgets/dialog/dialog_header.dart';
import 'package:trip_planner/features/budget/model/settlement_transaction_model.dart';

class DialogSettlement extends StatelessWidget {
  final List<SettlementTransaction> transactions;
  final double averagePerPerson;

  const DialogSettlement({
    super.key,
    required this.transactions,
    required this.averagePerPerson,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DialogHeader(
              title: "Rozliczenie wydatków",
              icon: Icons.wallet,
              onClose: () => Navigator.pop(context),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAverageInfo(),
                    const SizedBox(height: 20),
                    if (transactions.isEmpty)
                      _buildNoSettlementNeeded()
                    else
                      _buildTransactionsList(),
                  ],
                ),
              ),
            ),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAverageInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.limeSlice,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.limeSliceDark,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.limeSliceDark),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Średnio na osobę', style: AppTextStyles.bodyText),
                Text(
                  '${averagePerPerson.toStringAsFixed(2)} PLN',
                  style: AppTextStyles.priceTextSmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoSettlementNeeded() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 64,
            color: Colors.green.shade700,
          ),
          const SizedBox(height: 16),
          Text(
            'Świetnie!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Wszyscy zapłacili równo.\nNie ma potrzeby rozliczenia.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.swap_horiz, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              'Kto komu ma oddać:',
              style: AppTextStyles.heading3.copyWith(fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...transactions.asMap().entries.map((entry) {
          final index = entry.key;
          final transaction = entry.value;
          return _buildTransactionCard(transaction, index);
        }),
      ],
    );
  }

  Widget _buildTransactionCard(SettlementTransaction transaction, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.limeSlice,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 16,
                      color: AppColors.primaryDark,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        transaction.fromPersonName,
                        style: AppTextStyles.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'oddaje',
                  style: AppTextStyles.bodyTextSecondary,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        transaction.toPersonName,
                        style: AppTextStyles.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${transaction.amount.toStringAsFixed(2)}\nPLN',
              textAlign: TextAlign.center,
              style: AppTextStyles.priceTextWhite,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _copyToClipboard(context),
              icon: Icon(Icons.copy, color: AppColors.lightBlack),
              label: Text(
                'Kopiuj',
                style: AppTextStyles.buttonText,
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
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
                  child: const Text(
                    'Zamknij',
                    style: AppTextStyles.buttonText,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context) {
    final text = StringBuffer();
    text.writeln('🧾 Rozliczenie wydatków');
    text.writeln('');
    text.writeln(
        'Średnio na osobę: ${averagePerPerson.toStringAsFixed(2)} PLN');
    text.writeln('');

    if (transactions.isEmpty) {
      text.writeln('✅ Wszyscy zapłacili równo!');
    } else {
      text.writeln('💸 Kto komu ma oddać:');
      text.writeln('');
      for (int i = 0; i < transactions.length; i++) {
        final t = transactions[i];
        text.writeln(
          '${i + 1}. ${t.fromPersonName} → ${t.toPersonName}: ${t.amount.toStringAsFixed(2)} PLN',
        );
      }
    }

    Clipboard.setData(ClipboardData(text: text.toString()));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Skopiowano rozliczenie do schowka'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
