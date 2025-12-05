import 'package:flutter/material.dart';
import 'package:trip_planner/core/utils/validators.dart';
import 'package:trip_planner/core/widgets/dialog/dialog_actions_bar.dart';
import 'package:trip_planner/core/widgets/dialog/dialog_header.dart';
import 'package:trip_planner/features/budget/widgets/dialog/dialog_expense_inputs.dart';
import 'package:trip_planner/features/budget/model/budget_payer_selection_model.dart';
import 'package:trip_planner/features/budget/widgets/dialog/dialog_payer_selector.dart';

class ExpenseFormResult {
  final String title;
  final double amount;
  final BudgetPayerSelection payer;

  const ExpenseFormResult({
    required this.title,
    required this.amount,
    required this.payer,
  });
}

class DialogExpense extends StatefulWidget {
  const DialogExpense({
    super.key,
    this.initialTitle = '',
    this.initialAmount,
    this.initialPayer,
    this.tripId,
    this.isEditMode = false,
  });

  final String initialTitle;
  final double? initialAmount;
  final BudgetPayerSelection? initialPayer;
  final String? tripId;
  final bool isEditMode;

  @override
  State<DialogExpense> createState() => _ExpenseFormDialogState();
}

class _ExpenseFormDialogState extends State<DialogExpense> {
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late BudgetPayerSelection _payerSelection;

  String? _titleError;
  String? _amountError;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.initialTitle);
    _amountController = TextEditingController(
      text: widget.initialAmount != null
          ? widget.initialAmount!.toStringAsFixed(2)
          : '',
    );

    _payerSelection = widget.initialPayer ??
        const BudgetPayerSelection(
          payerName: null,
          payerUserId: null,
        );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _save() {
    final titleError = Validators.validateExpenseTitle(_titleController.text);
    final amountError = Validators.validateAmount(_amountController.text);

    setState(() {
      _titleError = titleError;
      _amountError = amountError;
    });

    if (titleError != null || amountError != null) return;

    final amountStr = _amountController.text.replaceAll(',', '.');
    final amount = double.parse(amountStr);

    final result = ExpenseFormResult(
      title: _titleController.text.trim(),
      amount: amount,
      payer: _payerSelection,
    );

    Navigator.pop(context, result);
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
                title: widget.isEditMode ? 'Edytuj wydatek' : 'Dodaj wydatek',
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
                onConfirm: _save,
                isEditing: widget.isEditMode,
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
