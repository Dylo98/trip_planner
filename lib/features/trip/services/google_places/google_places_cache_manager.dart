import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'google_places_models.dart';

/// Zarządza cache'owaniem wyników Google Places API

class GooglePlacesCacheManager {
  static const Duration _cacheExpiration = Duration(hours: 24);

  Future<List<GooglePlace>?> getPlaces(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final cached = prefs.getString(key);

      if (cached == null) return null;

      final data = json.decode(cached);

      final timestamp = DateTime.parse(data['timestamp']);

      if (DateTime.now().difference(timestamp) > _cacheExpiration) {
        await prefs.remove(key);

        return null;
      }

      return (data['places'] as List)
          .map((json) => GooglePlace.fromJson(json))
          .toList();
    } catch (e) {
      // Błąd podczas odczytu cache - zwróć null

      return null;
    }
  }

  Future<void> savePlaces(String key, List<GooglePlace> places) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final data = {
        'timestamp': DateTime.now().toIso8601String(),
        'places': places.map((p) => p.toJson()).toList(),
      };

      await prefs.setString(key, json.encode(data));
    } catch (e) {
      // Błąd podczas zapisu cache - ignoruj, nie krytyczne
    }
  }

  Future<GooglePlaceDetails?> getPlaceDetails(String placeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final key = 'details_$placeId';

      final cached = prefs.getString(key);

      if (cached == null) return null;

      final data = json.decode(cached);

      final timestamp = DateTime.parse(data['timestamp']);

      if (DateTime.now().difference(timestamp) > _cacheExpiration) {
        await prefs.remove(key);

        return null;
      }

      return GooglePlaceDetails.fromJson(data['details']);
    } catch (e) {
      // Błąd podczas odczytu cache - zwróć null

      return null;
    }
  }

  Future<void> savePlaceDetails(
    String placeId,
    GooglePlaceDetails details,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final key = 'details_$placeId';

      final data = {
        'timestamp': DateTime.now().toIso8601String(),
        'details': details.toJson(),
      };

      await prefs.setString(key, json.encode(data));
    } catch (e) {
      // Błąd podczas zapisu cache
    }
  }

  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final keys = prefs.getKeys();

      for (final key in keys) {
        if (key.startsWith('places_') || key.startsWith('details_')) {
          await prefs.remove(key);
        }
      }
    } catch (e) {
      // Błąd podczas czyszczenia cache - ignoruj
    }
  }
}
