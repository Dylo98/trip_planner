import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkerPoint {
  final String id;
  final LatLng position;
  final String? name;
  final String? description;
  final List<String>? imageUrl;
  final DateTime? arrivalDateTime;
  final DateTime? departureDateTime;
  final String? transportMode;

  MarkerPoint({
    required this.id,
    required this.position,
    this.name,
    this.description,
    this.imageUrl,
    this.arrivalDateTime,
    this.departureDateTime,
    this.transportMode,
  });

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
      'arrivalDateTime': arrivalDateTime?.toIso8601String(),
      'departureDateTime': departureDateTime?.toIso8601String(),
      'transportMode': transportMode,
    };
  }

  factory MarkerPoint.fromJson(Map<String, dynamic> json) {
    if (json['id'] == null || json['position'] == null) {
      throw FormatException('Invalid marker data: missing required fields');
    }
    final position = json['position'] as Map<String, dynamic>;
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
      arrivalDateTime: json['arrivalDateTime'] != null
          ? DateTime.parse(json['arrivalDateTime'])
          : null,
      departureDateTime: json['departureDateTime'] != null
          ? DateTime.parse(json['departureDateTime'])
          : null,
      transportMode: json['transportMode'] as String?,
    );
  }

  MarkerPoint copyWith({
    String? id,
    LatLng? position,
    String? name,
    String? description,
    List<String>? imageUrl,
    DateTime? arrivalDateTime,
    DateTime? departureDateTime,
    String? transportMode,
  }) {
    return MarkerPoint(
      id: id ?? this.id,
      position: position ?? this.position,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      arrivalDateTime: arrivalDateTime ?? this.arrivalDateTime,
      departureDateTime: departureDateTime ?? this.departureDateTime,
      transportMode: transportMode ?? this.transportMode,
    );
  }
}
