import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trip_planner/core/theme/input_style.dart';

class BudgetExpenseInputs extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController amountController;
  final String? titleError;
  final String? amountError;

  const BudgetExpenseInputs({
    super.key,
    required this.titleController,
    required this.amountController,
    this.titleError,
    this.amountError,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: titleController,
          decoration: AppInputStyle.inputDecoration(
            icon: Icons.title,
            labelText: 'Tytuł wydatku *',
            hintText: 'np. Paliwo, Zakupy, Parking',
            errorText: titleError,
          ),
          textCapitalization: TextCapitalization.sentences,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: amountController,
          decoration: AppInputStyle.inputDecoration(
            icon: Icons.attach_money,
            labelText: 'Kwota (PLN) *',
            hintText: '0.00',
            errorText: amountError,
          ),
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(
              RegExp(r'^\d+\.?\d{0,2}'),
            ),
          ],
        ),
      ],
    );
  }
}
