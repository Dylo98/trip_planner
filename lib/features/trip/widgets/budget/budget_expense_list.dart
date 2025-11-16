import 'package:flutter/material.dart';
import 'package:trip_planner/features/trip/model/expense_item_model.dart';

class BudgetExpenseList extends StatelessWidget {
  const BudgetExpenseList({
    super.key,
    required this.expensesByLocation,
    required this.expenseItemsByLocation,
    required this.totalExpense,
  });

  final Map<String, double> expensesByLocation;
  final Map<String, List<ExpenseItem>> expenseItemsByLocation;
  final double totalExpense;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Wydatki według miejsc',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...expensesByLocation.entries.map((entry) {
          final percentage = (entry.value / totalExpense) * 100;
          final items = expenseItemsByLocation[entry.key] ?? [];

          return _LocationExpenseCard(
            locationName: entry.key,
            totalAmount: entry.value,
            percentage: percentage,
            expenseItems: items,
          );
        }),
      ],
    );
  }
}

class _LocationExpenseCard extends StatefulWidget {
  const _LocationExpenseCard({
    required this.locationName,
    required this.totalAmount,
    required this.percentage,
    required this.expenseItems,
  });

  final String locationName;
  final double totalAmount;
  final double percentage;
  final List<ExpenseItem> expenseItems;

  @override
  State<_LocationExpenseCard> createState() => _LocationExpenseCardState();
}

class _LocationExpenseCardState extends State<_LocationExpenseCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        child: const Icon(Icons.place, color: Colors.blue),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.locationName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${widget.expenseItems.length} ${_getItemWord(widget.expenseItems.length)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${widget.totalAmount.toStringAsFixed(2)} PLN',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          Text(
                            '${widget.percentage.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: Colors.grey.shade600,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: widget.percentage / 100,
                    backgroundColor: Colors.grey.shade200,
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded) _buildExpenseDetails(),
        ],
      ),
    );
  }

  Widget _buildExpenseDetails() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: widget.expenseItems.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: Colors.grey.shade200,
        ),
        itemBuilder: (context, index) {
          final item = widget.expenseItems[index];
          return ListTile(
            dense: true,
            leading: Icon(
              Icons.receipt,
              color: Colors.grey.shade600,
              size: 20,
            ),
            title: Text(
              item.title,
              style: const TextStyle(fontSize: 14),
            ),
            subtitle: item.hasAssignedPayer
                ? Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 12,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item.displayPayerName,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  )
                : null,
            trailing: Text(
              '${item.amount.toStringAsFixed(2)} PLN',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.blue,
              ),
            ),
          );
        },
      ),
    );
  }

  String _getItemWord(int count) {
    if (count == 1) return 'wydatek';
    if (count % 10 >= 2 &&
        count % 10 <= 4 &&
        (count % 100 < 10 || count % 100 >= 20)) {
      return 'wydatki';
    }
    return 'wydatków';
  }
}
