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
    return MarkerPoint(
      id: json['id'],
      position: LatLng(
        json['position']['latitude'],
        json['position']['longitude'],
      ),
      name: json['name'],
      description: json['description'],
      imageUrl: List<String>.from(json['imageUrl'] ?? []),
      arrivalDateTime: json['arrivalDateTime'] != null
          ? DateTime.parse(json['arrivalDateTime'])
          : null,
      departureDateTime: json['departureDateTime'] != null
          ? DateTime.parse(json['departureDateTime'])
          : null,
      transportMode: json['transportMode'],
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
