import 'package:trip_planner/features/trip/model/marker_point_model.dart';

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
    TripType? tripType,
  }) : tripType =
            tripType ?? (endDate == null ? TripType.ongoing : TripType.planned);

  TripStatus get status {
    if (startDate == null) return TripStatus.upcoming;
    final now = DateTime.now();
    if (tripType == TripType.ongoing) {
      return now.isAfter(startDate!) ? TripStatus.ongoing : TripStatus.upcoming;
    }
    if (now.isBefore(startDate!)) {
      return TripStatus.upcoming;
    }
    if (endDate != null && now.isAfter(endDate!)) {
      return TripStatus.completed;
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
      'tripType': tripType.name,
    };
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
      tripType: tripType ?? this.tripType,
    );
  }
}
