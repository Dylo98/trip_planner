import 'package:flutter/material.dart';
import 'package:trip_planner/core/theme/colors.dart';
import 'package:trip_planner/core/theme/text_style.dart';
import 'package:trip_planner/features/budget/model/trip_expense_item_model.dart';

class BudgetGeneralSummary extends StatelessWidget {
  const BudgetGeneralSummary({
    super.key,
    required this.tripExpenses,
    required this.onEdit,
    required this.onDelete,
  });

  final List<TripExpenseItem> tripExpenses;
  final Function(TripExpenseItem) onEdit;
  final Function(TripExpenseItem) onDelete;

  double get _totalAmount {
    return tripExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  @override
  Widget build(BuildContext context) {
    if (tripExpenses.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.receipt_long,
              size: 20,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            const Text(
              'Wydatki ogólne',
              style: AppTextStyles.heading3,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Koszty nieprzypisane do konkretnych miejsc',
          style: AppTextStyles.bodyTextSecondary,
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 4,
          color: AppColors.limeSlice,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Suma wydatków ogólnych',
                          style: AppTextStyles.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_totalAmount.toStringAsFixed(2)} PLN',
                          style: AppTextStyles.priceTextLarge,
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${tripExpenses.length} ${_getExpenseWord(tripExpenses.length)}',
                        style: AppTextStyles.bodySmallWhite,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: tripExpenses.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final expense = tripExpenses[index];
                    return _buildExpenseItem(context, expense);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseItem(BuildContext context, TripExpenseItem expense) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: AppColors.limeSliceDark.withValues(alpha: 0.1),
        child: const Icon(
          Icons.receipt,
          color: AppColors.limeSliceDark,
          size: 20,
        ),
      ),
      title: Text(
        expense.title,
        style: AppTextStyles.bodyText,
      ),
      subtitle: expense.hasAssignedPayer
          ? Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 14,
                  color: AppColors.limeSliceDark,
                ),
                const SizedBox(width: 4),
                Text(
                  expense.displayPayerName,
                  style: AppTextStyles.bodyTextSecondary,
                ),
              ],
            )
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${expense.amount.toStringAsFixed(2)} PLN',
            style: AppTextStyles.priceTextSmall,
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'edit') {
                onEdit(expense);
              } else if (value == 'delete') {
                _showDeleteConfirmation(context, expense);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 20, color: AppColors.limeSliceDark),
                    SizedBox(width: 8),
                    Text('Edytuj', style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: AppColors.red, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Usuń',
                      style: AppTextStyles.bodySmallRed,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      onTap: () => onEdit(expense),
    );
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    TripExpenseItem expense,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Usuń wydatek'),
        content: Text(
          'Czy na pewno chcesz usunąć wydatek "${expense.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Anuluj'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Usuń'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      onDelete(expense);
    }
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
