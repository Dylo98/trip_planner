import 'package:flutter/material.dart';
import 'package:trip_planner/core/widgets/dialog/dialog_actions_bar.dart';
import 'package:trip_planner/features/budget/widgets/dialog/dialog_expense_inputs.dart';
import 'package:trip_planner/features/budget/model/budget_payer_selection_model.dart';
import 'package:uuid/uuid.dart';
import 'package:trip_planner/core/widgets/dialog/dialog_header.dart';
import 'package:trip_planner/features/budget/model/trip_expense_item_model.dart';
import 'package:trip_planner/features/budget/widgets/dialog/dialog_payer_selector.dart';

class DialogTripExpense extends StatefulWidget {
  const DialogTripExpense({
    super.key,
    this.expenseItem,
    this.tripId,
  });

  final TripExpenseItem? expenseItem;
  final String? tripId;

  @override
  State<DialogTripExpense> createState() => _TripExpenseDialogState();
}

class _TripExpenseDialogState extends State<DialogTripExpense> {
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late BudgetPayerSelection _payerSelection;

  String? _titleError;
  String? _amountError;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.expenseItem != null;

    _titleController = TextEditingController(
      text: widget.expenseItem?.title ?? '',
    );
    _amountController = TextEditingController(
      text: widget.expenseItem?.amount.toStringAsFixed(2) ?? '',
    );

    _payerSelection = BudgetPayerSelection(
      payerName: widget.expenseItem?.payerName,
      payerUserId: widget.expenseItem?.payerUserId,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _saveExpense() {
    setState(() {
      _titleError = null;
      _amountError = null;
    });

    final title = _titleController.text.trim();
    if (title.isEmpty) {
      _titleError = 'Wpisz tytuł wydatku';
    }

    final amountStr = _amountController.text.replaceAll(',', '.');
    final amount = double.tryParse(amountStr);

    if (amount == null || amount <= 0) {
      _amountError = 'Wpisz poprawną kwotę';
    }

    if (_titleError != null || _amountError != null) {
      setState(() {});
      return;
    }

    final expense = TripExpenseItem(
      id: widget.expenseItem?.id ?? const Uuid().v4(),
      title: title,
      amount: amount!,
      payerName: _payerSelection.payerName,
      payerUserId: _payerSelection.payerUserId,
      createdAt: widget.expenseItem?.createdAt ?? DateTime.now(),
    );

    Navigator.pop(context, expense);
  }

  @override
  Widget build(BuildContext context) {
    const radius = 24.0;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 500,
            maxHeight: 600,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DialogHeader(
                title: _isEditMode ? 'Edytuj wydatek' : 'Dodaj wydatek',
                icon: Icons.attach_money,
                onClose: () => Navigator.pop(context),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BudgetExpenseInputs(
                        titleController: _titleController,
                        amountController: _amountController,
                        titleError: _titleError,
                        amountError: _amountError,
                      ),
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 12),
                      DialogPayerSelector(
                        tripId: widget.tripId,
                        initialPayerName: _payerSelection.payerName,
                        initialPayerUserId: _payerSelection.payerUserId,
                        onChanged: (selection) {
                          _payerSelection = selection;
                        },
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
              DialogActionsBar(
                onCancel: () => Navigator.pop(context),
                onConfirm: _saveExpense,
                isEditing: _isEditMode,
                addLabel: 'Dodaj',
                saveLabel: 'Zapisz',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
