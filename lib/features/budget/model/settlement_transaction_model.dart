class SettlementTransaction {
  final String fromPersonName;
  final String? fromPersonUserId;
  final String toPersonName;
  final String? toPersonUserId;
  final double amount;

  const SettlementTransaction({
    required this.fromPersonName,
    this.fromPersonUserId,
    required this.toPersonName,
    this.toPersonUserId,
    required this.amount,
  });

  @override
  String toString() {
    return '$fromPersonName → $toPersonName: ${amount.toStringAsFixed(2)} PLN';
  }
}
