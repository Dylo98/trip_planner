import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:trip_planner/features/trip/model/expense_item_model.dart';
import 'package:trip_planner/features/trip/model/marker_point_model.dart';
import 'package:trip_planner/features/trip/widgets/marker_details_sheet/expense_item_dialog.dart';

class MarkerExpensesSection extends ConsumerStatefulWidget {
  const MarkerExpensesSection({
    super.key,
    required this.marker,
    required this.onExpensesChanged,
    this.tripId,
  });

  final MarkerPoint marker;
  final Function(List<ExpenseItem>) onExpensesChanged;
  final String? tripId;

  @override
  ConsumerState<MarkerExpensesSection> createState() =>
      _MarkerExpensesSectionState();
}

class _MarkerExpensesSectionState extends ConsumerState<MarkerExpensesSection> {
  late List<ExpenseItem> _expenses;

  @override
  void initState() {
    super.initState();
    _expenses = widget.marker.expenses ?? [];

    if (_expenses.isEmpty &&
        widget.marker.expense != null &&
        widget.marker.expense! > 0) {
      _expenses = [
        ExpenseItem(
          id: const Uuid().v4(),
          title: 'Wydatek',
          amount: widget.marker.expense!,
        ),
      ];
    }
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
                      color: Colors.grey.shade700,
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
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
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
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
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
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: const Icon(
                Icons.receipt,
                color: Colors.blue,
                size: 20,
              ),
            ),
            title: Text(
              expense.title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
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
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${expense.amount.toStringAsFixed(2)} PLN',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
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
                          Icon(Icons.delete, color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Usuń',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            onTap: () => _editExpense(index),
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
            style: TextButton.styleFrom(foregroundColor: Colors.red),
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
