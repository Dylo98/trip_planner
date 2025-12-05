import 'package:trip_planner/features/trip/model/marker_point_model.dart';
import 'package:trip_planner/features/budget/model/expense_item_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum TripType {
  planned,
  ongoing,
}

enum TripStatus {
  upcoming,
  ongoing,
  completed,
}

class Trip {
  final String id;
  final String name;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? description;
  final List<String>? imageUrl;
  final String? tripPhotoUrl;
  final List<MarkerPoint> markerPoints;
  final List<ExpenseItem>? tripExpenses;
  final TripType tripType;

  Trip({
    required this.id,
    required this.name,
    required this.startDate,
    this.endDate,
    this.description,
    this.imageUrl,
    this.tripPhotoUrl,
    required this.markerPoints,
    this.tripExpenses,
    TripType? tripType,
  }) : tripType =
            tripType ?? (endDate == null ? TripType.ongoing : TripType.planned);

  TripStatus get status {
    if (startDate == null) return TripStatus.upcoming;
    final now = DateTime.now();

    if (endDate != null && now.isAfter(endDate!)) {
      return TripStatus.completed;
    }
    if (now.isBefore(startDate!)) {
      return TripStatus.upcoming;
    }

    return TripStatus.ongoing;
  }

  int get durationInDays {
    if (startDate == null) return 0;
    if (endDate == null) return 1;
    return endDate!.difference(startDate!).inDays + 1;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'description': description,
      'imageUrl': imageUrl,
      'tripPhotoUrl': tripPhotoUrl,
      'markerPoints': markerPoints.map((marker) => marker.toJson()).toList(),
      'tripExpenses': tripExpenses?.map((expense) => expense.toJson()).toList(),
      'tripType': tripType.name,
    };
  }

  factory Trip.fromFirestore(Map<String, dynamic> data) {
    TripType? parsedType;
    if (data['tripType'] != null) {
      try {
        parsedType = TripType.values.firstWhere(
          (e) => e.name == data['tripType'],
        );
      } catch (e) {
        parsedType = null;
      }
    }

    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.parse(value);
      return null;
    }

    return Trip(
      id: data['id'],
      name: data['name'],
      startDate: parseDate(data['startDate']),
      endDate: parseDate(data['endDate']),
      description: data['description'] as String?,
      imageUrl:
          data['imageUrl'] != null ? List<String>.from(data['imageUrl']) : [],
      tripPhotoUrl: data['tripPhotoUrl'] as String?,
      markerPoints: data['markerPoints'] != null
          ? (data['markerPoints'] as List)
              .map((m) => MarkerPoint.fromJson(m))
              .toList()
          : [],
      tripExpenses: data['tripExpenses'] != null
          ? (data['tripExpenses'] as List)
              .map((e) => ExpenseItem.fromJson(e))
              .toList()
          : null,
      tripType: parsedType,
    );
  }

  factory Trip.fromJson(Map<String, dynamic> json) {
    TripType? parsedType;
    if (json['tripType'] != null) {
      try {
        parsedType = TripType.values.firstWhere(
          (e) => e.name == json['tripType'],
        );
      } catch (e) {
        parsedType = null;
      }
    }
    return Trip(
      id: json['id'],
      name: json['name'],
      startDate:
          json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      description: json['description'] as String?,
      imageUrl:
          json['imageUrl'] != null ? List<String>.from(json['imageUrl']) : [],
      tripPhotoUrl: json['tripPhotoUrl'] as String?,
      markerPoints: json['markerPoints'] != null
          ? (json['markerPoints'] as List)
              .map((m) => MarkerPoint.fromJson(m))
              .toList()
          : [],
      tripExpenses: json['tripExpenses'] != null
          ? (json['tripExpenses'] as List)
              .map((e) => ExpenseItem.fromJson(e))
              .toList()
          : null,
      tripType: parsedType,
    );
  }

  Trip copyWith({
    String? id,
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    String? description,
    List<String>? imageUrl,
    String? tripPhotoUrl,
    List<MarkerPoint>? markerPoints,
    List<ExpenseItem>? tripExpenses,
    TripType? tripType,
  }) {
    return Trip(
      id: id ?? this.id,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      tripPhotoUrl: tripPhotoUrl ?? this.tripPhotoUrl,
      markerPoints: markerPoints ?? this.markerPoints,
      tripExpenses: tripExpenses ?? this.tripExpenses,
      tripType: tripType ?? this.tripType,
    );
  }
}
