import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

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
      debugPrint('Cache read error: $e');
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
      debugPrint('Cache save error: $e');
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
      debugPrint('Details cache read error: $e');
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
      debugPrint('Details cache save error: $e');
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

      debugPrint('✅ Cache wyczyszczona');
    } catch (e) {
      debugPrint('Cache clear error: $e');
    }
  }
}
