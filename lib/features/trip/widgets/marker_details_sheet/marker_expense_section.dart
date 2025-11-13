import 'package:flutter/material.dart';
import 'package:trip_planner/core/utils/debouncer.dart';

class MarkerExpenseSection extends StatefulWidget {
  const MarkerExpenseSection({
    super.key,
    required this.initialExpense,
    required this.onExpenseChanged,
  });

  final double? initialExpense;
  final Function(double) onExpenseChanged;

  @override
  State<MarkerExpenseSection> createState() => _MarkerExpenseSectionState();
}

class _MarkerExpenseSectionState extends State<MarkerExpenseSection> {
  late final TextEditingController _controller;
  final _debouncer = Debouncer(milliseconds: 600);

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialExpense?.toStringAsFixed(2) ?? '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 32),
        TextFormField(
          controller: _controller,
          decoration: const InputDecoration(
            labelText: 'Wydatek (PLN)',
            hintText: 'Wprowadź kwotę',
            prefixIcon: Icon(Icons.attach_money),
            border: OutlineInputBorder(),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (v) {
            _debouncer.run(() async {
              final parsed = double.tryParse(
                _controller.text.replaceAll(',', '.'),
              );
              if (parsed != null) {
                widget.onExpenseChanged(parsed);
              }
            });
          },
        ),
      ],
    );
  }
}
