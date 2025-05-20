import 'package:trip_planner/features/trip/model/marker_point_model.dart';

class Trip {
  final String id;
  final String name;
  final DateTime startDate;
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
}
