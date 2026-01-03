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

  static TripType? _parseTripType(dynamic value) {
    if (value == null) return null;
    try {
      return TripType.values.firstWhere((e) => e.name == value);
    } catch (e) {
      return null;
    }
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.parse(value);
    return null;
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

  static List<MarkerPoint> _parseMarkerPoints(dynamic value) {
    if (value == null) return [];

    return (value as List).map((m) => MarkerPoint.fromJson(m)).toList();
  }

  static List<ExpenseItem>? _parseExpenses(dynamic value) {
    if (value == null) return null;

    return (value as List).map((e) => ExpenseItem.fromJson(e)).toList();
  }

  static List<String> _parseImageUrls(dynamic value) {
    if (value == null) return [];

    return List<String>.from(value);
  }

  factory Trip.fromFirestore(Map<String, dynamic> data) {
    return Trip(
      id: data['id'],
      name: data['name'],
      startDate: _parseDate(data['startDate']),
      endDate: _parseDate(data['endDate']),
      description: data['description'] as String?,
      imageUrl: _parseImageUrls(data['imageUrl']),
      tripPhotoUrl: data['tripPhotoUrl'] as String?,
      markerPoints: _parseMarkerPoints(data['markerPoints']),
      tripExpenses: _parseExpenses(data['tripExpenses']),
      tripType: _parseTripType(data['tripType']),
    );
  }

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'],
      name: json['name'],
      startDate: _parseDate(json['startDate']),
      endDate: _parseDate(json['endDate']),
      description: json['description'] as String?,
      imageUrl: _parseImageUrls(json['imageUrl']),
      tripPhotoUrl: json['tripPhotoUrl'] as String?,
      markerPoints: _parseMarkerPoints(json['markerPoints']),
      tripExpenses: _parseExpenses(json['tripExpenses']),
      tripType: _parseTripType(json['tripType']),
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
