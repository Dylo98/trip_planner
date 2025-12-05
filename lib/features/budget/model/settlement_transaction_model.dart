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

  String get formattedAmount => '${amount.toStringAsFixed(2)} PLN';
  bool get hasUserIds => fromPersonUserId != null && toPersonUserId != null;

  SettlementTransaction copyWith({
    String? fromPersonName,
    String? fromPersonUserId,
    String? toPersonName,
    String? toPersonUserId,
    double? amount,
  }) {
    return SettlementTransaction(
      fromPersonName: fromPersonName ?? this.fromPersonName,
      fromPersonUserId: fromPersonUserId ?? this.fromPersonUserId,
      toPersonName: toPersonName ?? this.toPersonName,
      toPersonUserId: toPersonUserId ?? this.toPersonUserId,
      amount: amount ?? this.amount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fromPersonName': fromPersonName,
      'fromPersonUserId': fromPersonUserId,
      'toPersonName': toPersonName,
      'toPersonUserId': toPersonUserId,
      'amount': amount,
    };
  }

  factory SettlementTransaction.fromJson(Map<String, dynamic> json) {
    return SettlementTransaction(
      fromPersonName: json['fromPersonName'] as String,
      fromPersonUserId: json['fromPersonUserId'] as String?,
      toPersonName: json['toPersonName'] as String,
      toPersonUserId: json['toPersonUserId'] as String?,
      amount: (json['amount'] as num).toDouble(),
    );
  }

  @override
  String toString() {
    return '$fromPersonName → $toPersonName: $formattedAmount';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SettlementTransaction &&
        other.fromPersonName == fromPersonName &&
        other.toPersonName == toPersonName &&
        other.amount == amount;
  }

  @override
  int get hashCode {
    return fromPersonName.hashCode ^ toPersonName.hashCode ^ amount.hashCode;
  }
}
