import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TripDateRange extends StatelessWidget {
  const TripDateRange({
    super.key,
    required this.startDate,
    this.endDate,
  });

  final DateTime? startDate;
  final DateTime? endDate;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          startDate != null
              ? DateFormat('dd-MM-yyyy').format(startDate!)
              : 'Brak daty',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Icon(Icons.arrow_right, size: 24),
        Text(
          endDate != null ? DateFormat('dd-MM-yyyy').format(endDate!) : '...',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
