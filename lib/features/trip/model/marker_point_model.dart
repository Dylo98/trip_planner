import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkerPoint {
  final String id;
  final LatLng position;
  final String? name;
  final String? description;
  final List<String>? imageUrl;

  MarkerPoint({
    required this.id,
    required this.position,
    this.name,
    this.description,
    this.imageUrl,
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
    );
  }
}
