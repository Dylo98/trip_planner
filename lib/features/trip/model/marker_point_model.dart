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
}
