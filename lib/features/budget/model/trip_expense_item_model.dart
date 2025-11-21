class TripExpenseItem {
  final String id;
  final String title;
  final double amount;
  final String? payerName;
  final String? payerUserId;
  final DateTime createdAt;
  final String? category;

  TripExpenseItem({
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

  factory TripExpenseItem.fromJson(Map<String, dynamic> json) {
    return TripExpenseItem(
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

  TripExpenseItem copyWith({
    String? id,
    String? title,
    double? amount,
    String? payerName,
    String? payerUserId,
    DateTime? createdAt,
    String? category,
  }) {
    return TripExpenseItem(
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
