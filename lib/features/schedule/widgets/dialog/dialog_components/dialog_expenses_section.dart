import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:trip_planner/core/theme/colors.dart';
import 'package:trip_planner/core/theme/text_style.dart';
import 'package:trip_planner/features/budget/model/expense_item_model.dart';
import 'package:trip_planner/features/schedule/model/day_plan_item_model.dart';
import 'package:trip_planner/features/budget/model/budget_payer_selection_model.dart';
import 'package:trip_planner/features/budget/widgets/dialog/dialog_expense.dart';

class DialogExpensesSection extends ConsumerStatefulWidget {
  const DialogExpensesSection({
    super.key,
    required this.item,
    required this.onExpensesChanged,
    this.tripId,
  });

  final DayPlanItem item;
  final Function(List<ExpenseItem>) onExpensesChanged;
  final String? tripId;

  @override
  ConsumerState<DialogExpensesSection> createState() =>
      _DayPlanItemExpensesSectionState();
}

class _DayPlanItemExpensesSectionState
    extends ConsumerState<DialogExpensesSection> {
  late List<ExpenseItem> _expenses;

  @override
  void initState() {
    super.initState();
    _expenses = widget.item.expenses ?? [];
  }

  double get _totalExpense {
    return _expenses.fold(0.0, (sum, item) => sum + item.amount);
  }

  Future<void> _addExpense() async {
    final formResult = await showDialog<ExpenseFormResult>(
      context: context,
      builder: (context) => DialogExpense(
        tripId: widget.tripId,
        isEditMode: false,
      ),
    );

    if (formResult != null) {
      final newExpense = ExpenseItem(
        id: const Uuid().v4(),
        title: formResult.title,
        amount: formResult.amount,
        payerName: formResult.payer.payerName,
        payerUserId: formResult.payer.payerUserId,
        createdAt: DateTime.now(),
      );

      setState(() {
        _expenses.add(newExpense);
      });
      widget.onExpensesChanged(_expenses);
    }
  }

  Future<void> _editExpense(int index) async {
    final current = _expenses[index];

    final formResult = await showDialog<ExpenseFormResult>(
      context: context,
      builder: (context) => DialogExpense(
        tripId: widget.tripId,
        isEditMode: true,
        initialTitle: current.title,
        initialAmount: current.amount,
        initialPayer: BudgetPayerSelection(
          payerName: current.payerName,
          payerUserId: current.payerUserId,
        ),
      ),
    );

    if (formResult != null) {
      final updated = ExpenseItem(
        id: current.id,
        title: formResult.title,
        amount: formResult.amount,
        payerName: formResult.payer.payerName,
        payerUserId: formResult.payer.payerUserId,
        createdAt: current.createdAt,
      );

      setState(() {
        _expenses[index] = updated;
      });
      widget.onExpensesChanged(_expenses);
    }
  }

  void _deleteExpense(int index) {
    setState(() {
      _expenses.removeAt(index);
    });
    widget.onExpensesChanged(_expenses);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Wydatki',
                  style: AppTextStyles.heading3,
                ),
                if (_expenses.isNotEmpty)
                  Text(
                    'Suma: ${_totalExpense.toStringAsFixed(2)} PLN',
                    style: AppTextStyles.bodyTextSecondary,
                  ),
              ],
            ),
            IconButton.filled(
              icon: const Icon(Icons.add),
              onPressed: _addExpense,
              style: IconButton.styleFrom(
                backgroundColor: AppColors.surface,
                foregroundColor: AppColors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_expenses.isEmpty)
          Center(child: _buildEmptyState())
        else
          _buildExpensesList(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        Icon(
          Icons.receipt_long_outlined,
          size: 48,
          color: AppColors.textSecondary,
        ),
        const SizedBox(height: 12),
        Text(
          'Brak wydatków',
          style: AppTextStyles.bodyTextSecondaryBig,
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _buildExpensesList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _expenses.length,
      itemBuilder: (context, index) {
        final expense = _expenses[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 4,
          color: AppColors.limeSlice,
          child: InkWell(
            onTap: () => _editExpense(index),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          expense.title,
                          style: AppTextStyles.bodyText,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
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
                            ),
                            Text(
                              '${expense.amount.toStringAsFixed(2)} PLN',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: AppColors.surface,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      if (value == 'edit') {
                        _editExpense(index);
                      } else if (value == 'delete') {
                        _showDeleteConfirmation(index);
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Edytuj', style: AppTextStyles.bodySmall),
                          ],
                        ),
                      ),
                      PopupMenuItem(
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
            ),
          ),
        );
      },
    );
  }

  Future<void> _showDeleteConfirmation(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Usuń wydatek'),
        content: Text(
          'Czy na pewno chcesz usunąć wydatek "${_expenses[index].title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Anuluj'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.red),
            child: const Text('Usuń'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _deleteExpense(index);
    }
  }
}
