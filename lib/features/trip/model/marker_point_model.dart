class MarkerPoint {
  final String id;
  final double latitude;
  final double longitude;
  final String? name;
  final String? description;
  final List<String>? imageUrl;

  MarkerPoint({
    required this.id,
    required this.latitude,
    required this.longitude,
    this.name,
    this.description,
    this.imageUrl,
  });
}
