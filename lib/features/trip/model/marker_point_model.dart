import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trip_planner/features/trip/model/expense_item_model.dart';

class MarkerPoint {
  final String id;
  final LatLng position;
  final String? name;
  final String? description;
  final List<String>? imageUrl;
  final String? transportMode;
  final List<ExpenseItem>? expenses;

  @Deprecated('Użyj expenses zamiast expense')
  final double? expense;

  MarkerPoint({
    required this.id,
    required this.position,
    this.name,
    this.description,
    this.imageUrl,
    this.transportMode,
    this.expenses,
    this.expense,
  });

  double get totalExpense {
    if (expenses == null || expenses!.isEmpty) {
      return expense ?? 0.0;
    }
    return expenses!.fold(0.0, (sum, item) => sum + item.amount);
  }

  bool get hasExpenses {
    return (expenses != null && expenses!.isNotEmpty) ||
        (expense != null && expense! > 0);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'position': {
        'latitude': position.latitude,
        'longitude': position.longitude,
      },
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'transportMode': transportMode,
      'expenses': expenses?.map((e) => e.toJson()).toList(),
      if (expense != null) 'expense': expense,
    };
  }

  factory MarkerPoint.fromJson(Map<String, dynamic> json) {
    if (json['id'] == null || json['position'] == null) {
      throw FormatException('Invalid marker data: missing required fields');
    }
    final position = json['position'] as Map<String, dynamic>;

    List<ExpenseItem>? expensesList;
    if (json['expenses'] != null) {
      expensesList = (json['expenses'] as List)
          .map((e) => ExpenseItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    double? oldExpense;
    if (json['expense'] != null) {
      oldExpense = (json['expense'] as num).toDouble();
    }

    return MarkerPoint(
      id: json['id'] as String,
      position: LatLng(
        (position['latitude'] as num).toDouble(),
        (position['longitude'] as num).toDouble(),
      ),
      name: json['name'] as String?,
      description: json['description'] as String?,
      imageUrl:
          json['imageUrl'] != null ? List<String>.from(json['imageUrl']) : null,
      transportMode: json['transportMode'] as String?,
      expenses: expensesList,
      expense: oldExpense,
    );
  }

  MarkerPoint copyWith({
    String? id,
    LatLng? position,
    String? name,
    String? description,
    List<String>? imageUrl,
    String? transportMode,
    List<ExpenseItem>? expenses,
    double? expense,
  }) {
    return MarkerPoint(
      id: id ?? this.id,
      position: position ?? this.position,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      transportMode: transportMode ?? this.transportMode,
      expenses: expenses ?? this.expenses,
      expense: expense ?? this.expense,
    );
  }
}
