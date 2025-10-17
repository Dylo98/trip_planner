import 'package:trip_planner/features/trip/model/marker_point_model.dart';

class Trip {
  final String id;
  final String name;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? description;
  final List<String>? imageUrl;
  final String? tripPhotoUrl;
  final List<MarkerPoint> markerPoints;

  Trip({
    required this.id,
    required this.name,
    required this.startDate,
    this.endDate,
    this.description,
    this.imageUrl,
    this.tripPhotoUrl,
    required this.markerPoints,
  });

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
    };
  }

  factory Trip.fromJson(Map<String, dynamic> json) {
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
    );
  }
}
