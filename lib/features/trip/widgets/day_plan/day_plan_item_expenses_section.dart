import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/core/theme/colors.dart';
import 'package:trip_planner/features/trip/model/expense_item_model.dart';
import 'package:trip_planner/features/trip/model/day_plan_item_model.dart';
import 'package:trip_planner/features/trip/widgets/marker_details_sheet/expense_item_dialog.dart';

/// Widget sekcji wydatków dla aktywności w planie dnia
///
/// Umożliwia:
/// - Dodawanie wydatków do aktywności
/// - Edycję istniejących wydatków
/// - Usuwanie wydatków
/// - Wyświetlanie sumy wydatków
class DayPlanItemExpensesSection extends ConsumerStatefulWidget {
  const DayPlanItemExpensesSection({
    super.key,
    required this.item,
    required this.onExpensesChanged,
    this.tripId,
  });

  final DayPlanItem item;
  final Function(List<ExpenseItem>) onExpensesChanged;
  final String? tripId;

  @override
  ConsumerState<DayPlanItemExpensesSection> createState() =>
      _DayPlanItemExpensesSectionState();
}

class _DayPlanItemExpensesSectionState
    extends ConsumerState<DayPlanItemExpensesSection> {
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
    final result = await showDialog<ExpenseItem>(
      context: context,
      builder: (context) => ExpenseItemDialog(
        tripId: widget.tripId,
      ),
    );

    if (result != null) {
      setState(() {
        _expenses.add(result);
      });
      widget.onExpensesChanged(_expenses);
    }
  }

  Future<void> _editExpense(int index) async {
    final result = await showDialog<ExpenseItem>(
      context: context,
      builder: (context) => ExpenseItemDialog(
        expenseItem: _expenses[index],
        tripId: widget.tripId,
      ),
    );

    if (result != null) {
      setState(() {
        _expenses[index] = result;
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
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_expenses.isNotEmpty)
                  Text(
                    'Suma: ${_totalExpense.toStringAsFixed(2)} PLN',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.darkGrey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
            IconButton.filled(
              icon: const Icon(Icons.add),
              onPressed: _addExpense,
              tooltip: 'Dodaj wydatek',
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_expenses.isEmpty) _buildEmptyState() else _buildExpensesList(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey),
      ),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            'Brak wydatków',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Kliknij + aby dodać wydatek',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
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
          elevation: 2,
          child: InkWell(
            onTap: () => _editExpense(index),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.green.shade100,
                    child: const Icon(
                      Icons.receipt,
                      color: Colors.green,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          expense.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
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
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  expense.displayPayerName,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '${expense.amount.toStringAsFixed(2)} PLN',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: AppColors.primary,
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
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Edytuj'),
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
                              style: TextStyle(color: AppColors.red),
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
