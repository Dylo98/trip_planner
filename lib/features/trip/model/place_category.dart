import 'package:flutter/material.dart';

enum PlaceCategory {
  all(
    'Wszystko',
    Icons.explore,
    [],
  ),
  restaurants(
    'Restauracje',
    Icons.restaurant,
    ['restaurant', 'cafe', 'bar'],
  ),
  attractions(
    'Atrakcje',
    Icons.attractions,
    [
      'tourist_attraction',
      'museum',
      'art_gallery',
      'zoo',
      'aquarium',
      'amusement_park',
    ],
  ),
  culture(
    'Kultura',
    Icons.theater_comedy,
    ['museum', 'art_gallery', 'library', 'theater', 'concert_hall'],
  ),
  nature(
    'Natura',
    Icons.park,
    ['park', 'natural_feature', 'campground'],
  ),
  shopping(
    'Zakupy',
    Icons.shopping_bag,
    ['shopping_mall', 'store', 'supermarket'],
  ),
  entertainment(
    'Rozrywka',
    Icons.local_activity,
    ['movie_theater', 'night_club', 'casino', 'bowling_alley'],
  );

  final String label;

  final IconData icon;

  final List<String> types;

  const PlaceCategory(this.label, this.icon, this.types);

  Color get color {
    switch (this) {
      case PlaceCategory.all:
        return Colors.blue;
      case PlaceCategory.restaurants:
        return Colors.orange;
      case PlaceCategory.attractions:
        return Colors.purple;
      case PlaceCategory.culture:
        return Colors.pink;
      case PlaceCategory.nature:
        return Colors.green;
      case PlaceCategory.shopping:
        return Colors.teal;
      case PlaceCategory.entertainment:
        return Colors.red;
    }
  }

  bool get hasSpecificTypes => types.isNotEmpty;
}
