class ExpenseItem {
  final String id;
  final String title;
  final double amount;
  final String? payerName;
  final String? payerUserId;
  final DateTime createdAt;
  final String? category;

  ExpenseItem({
    required this.id,
    required this.title,
    required this.amount,
    this.payerName,
    this.payerUserId,
    DateTime? createdAt,
    this.category,
  }) : createdAt = createdAt ?? DateTime.now();

  String get displayPayerName {
    if (payerName != null && payerName!.isNotEmpty) {
      return payerName!;
    }
    return 'Nie określono';
  }

  bool get hasAssignedPayer => payerName != null && payerName!.isNotEmpty;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'payerName': payerName,
      'payerUserId': payerUserId,
      'createdAt': createdAt.toIso8601String(),
      'category': category,
    };
  }

  factory ExpenseItem.fromJson(Map<String, dynamic> json) {
    return ExpenseItem(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      payerName: json['payerName'] as String?,
      payerUserId: json['payerUserId'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      category: json['category'] as String?,
    );
  }

  ExpenseItem copyWith({
    String? id,
    String? title,
    double? amount,
    String? payerName,
    String? payerUserId,
    DateTime? createdAt,
    String? category,
  }) {
    return ExpenseItem(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      payerName: payerName ?? this.payerName,
      payerUserId: payerUserId ?? this.payerUserId,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
    );
  }
}
