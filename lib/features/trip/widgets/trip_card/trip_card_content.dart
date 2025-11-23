import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TripCardContent extends StatelessWidget {
  const TripCardContent({
    super.key,
    required this.tripName,
    required this.formattedStartDate,
    required this.totalBudget,
  });

  final String tripName;
  final String formattedStartDate;
  final double totalBudget;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildTripName(),
          const SizedBox(height: 4),
          _buildStartDate(),
          if (totalBudget > 0) ...[
            const SizedBox(height: 8),
            _buildBudget(),
          ],
        ],
      ),
    );
  }

  Widget _buildTripName() {
    return Text(
      tripName,
      style: GoogleFonts.bebasNeue().copyWith(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildStartDate() {
    return Text(
      formattedStartDate,
      style: GoogleFonts.bebasNeue().copyWith(
        color: const Color(0xFFB9F90B),
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildBudget() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.account_balance_wallet,
            color: Colors.white,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            '${totalBudget.toStringAsFixed(2)} PLN',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
