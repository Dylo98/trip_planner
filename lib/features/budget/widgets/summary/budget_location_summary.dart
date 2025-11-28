import 'package:flutter/material.dart';
import 'package:trip_planner/core/theme/colors.dart';
import 'package:trip_planner/core/theme/text_style.dart';
import 'package:trip_planner/features/budget/model/expense_item_model.dart';
import 'package:trip_planner/core/utils/location_name.dart';

class BudgetLocationSummary extends StatelessWidget {
  const BudgetLocationSummary({
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
        Row(
          children: [
            Icon(
              Icons.location_city,
              size: 20,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Wydatki według miejsc',
              style: AppTextStyles.heading3,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Koszty przypisane do konkretnych miejsc',
          style: AppTextStyles.bodyTextSecondary,
        ),
        const SizedBox(height: 12),
        ...expensesByLocation.entries.map((entry) {
          final percentage = (entry.value / totalExpense) * 100;
          final items = expenseItemsByLocation[entry.key] ?? [];

          final shortLocationName = LocationName.getShortName(entry.key);

          return _LocationExpenseCard(
            locationName: shortLocationName,
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
      color: AppColors.limeSlice,
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
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${widget.totalAmount.toStringAsFixed(2)} PLN',
                            style: AppTextStyles.priceTextSmall,
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: AppColors.limeSliceDark,
                      ),
                    ],
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
        color: AppColors.limeSliceLight,
        border: Border(
          top: BorderSide(color: AppColors.limeSliceDark),
        ),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: widget.expenseItems.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: AppColors.limeSlice,
        ),
        itemBuilder: (context, index) {
          final item = widget.expenseItems[index];
          return ListTile(
            dense: true,
            leading: Icon(
              Icons.receipt,
              color: AppColors.limeSliceDark,
              size: 20,
            ),
            title: Text(
              item.title,
              style: AppTextStyles.bodyText,
            ),
            subtitle: item.hasAssignedPayer
                ? Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 12,
                        color: AppColors.limeSliceDark,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item.displayPayerName,
                        style: AppTextStyles.bodyTextSecondary,
                      ),
                    ],
                  )
                : null,
            trailing: Text(
              '${item.amount.toStringAsFixed(2)} PLN',
              style: AppTextStyles.priceTextVerySmall,
            ),
          );
        },
      ),
    );
  }
}
