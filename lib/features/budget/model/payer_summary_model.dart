class PayerSummary {
  final String payerName;
  final String? payerUserId;
  final double totalAmount;
  final int expenseCount;

  const PayerSummary({
    required this.payerName,
    this.payerUserId,
    required this.totalAmount,
    required this.expenseCount,
  });

  double calculatePercentage(double totalExpense) {
    if (totalExpense == 0) return 0;
    return (totalAmount / totalExpense) * 100;
  }

  bool get hasExpenses => totalAmount > 0;
  bool get hasUserId => payerUserId != null;

  PayerSummary copyWith({
    String? payerName,
    String? payerUserId,
    double? totalAmount,
    int? expenseCount,
  }) {
    return PayerSummary(
      payerName: payerName ?? this.payerName,
      payerUserId: payerUserId ?? this.payerUserId,
      totalAmount: totalAmount ?? this.totalAmount,
      expenseCount: expenseCount ?? this.expenseCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'payerName': payerName,
      'payerUserId': payerUserId,
      'totalAmount': totalAmount,
      'expenseCount': expenseCount,
    };
  }

  factory PayerSummary.fromJson(Map<String, dynamic> json) {
    return PayerSummary(
      payerName: json['payerName'] as String,
      payerUserId: json['payerUserId'] as String?,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      expenseCount: json['expenseCount'] as int,
    );
  }

  @override
  String toString() {
    return 'PayerSummary(payerName: $payerName, totalAmount: $totalAmount, expenseCount: $expenseCount)';
  }
}
