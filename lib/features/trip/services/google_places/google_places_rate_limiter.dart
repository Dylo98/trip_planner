import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

import 'google_places_models.dart';

class GooglePlacesRateLimiter {
  static const int _maxRequestsPerMinute = 20;
  static const int _maxRequestsPerDay = 300;

  static const double costNearbySearch = 0.032;
  static const double costPlaceDetails = 0.017;
  static const double costPhoto = 0.007;

  static final List<DateTime> _requestTimestamps = [];
  static int _dailyRequestCount = 0;
  static DateTime? _lastResetDate;
  static double _totalCostToday = 0.0;

  Future<bool> canMakeRequest() async {
    final now = DateTime.now();

    if (_lastResetDate == null || !_isSameDay(_lastResetDate!, now)) {
      _dailyRequestCount = 0;
      _totalCostToday = 0.0;
      _lastResetDate = now;
      await _saveDailyStats();
    }

    if (_dailyRequestCount >= _maxRequestsPerDay) {
      debugPrint('🚫 LIMIT DZIENNY: $_dailyRequestCount/$_maxRequestsPerDay');
      debugPrint('   Koszt dzisiaj: \$${_totalCostToday.toStringAsFixed(2)}');
      return false;
    }

    final oneMinuteAgo = now.subtract(const Duration(minutes: 1));
    _requestTimestamps.removeWhere((ts) => ts.isBefore(oneMinuteAgo));

    if (_requestTimestamps.length >= _maxRequestsPerMinute) {
      debugPrint(
          '🚫 RATE LIMIT: ${_requestTimestamps.length}/$_maxRequestsPerMinute zapytań/min');
      return false;
    }

    return true;
  }

  void recordRequest(double cost) {
    _requestTimestamps.add(DateTime.now());
    _dailyRequestCount++;
    _totalCostToday += cost;
    _saveDailyStats();

    debugPrint('📊 Stats: $_dailyRequestCount/$_maxRequestsPerDay zapytań');
    debugPrint('   Koszt: \$${_totalCostToday.toStringAsFixed(3)} dzisiaj');
  }

  Future<CostStatistics> getStatistics() async {
    final now = DateTime.now();
    final oneMinuteAgo = now.subtract(const Duration(minutes: 1));
    _requestTimestamps.removeWhere((ts) => ts.isBefore(oneMinuteAgo));

    return CostStatistics(
      dailyRequests: _dailyRequestCount,
      maxDailyRequests: _maxRequestsPerDay,
      totalCostToday: _totalCostToday,
      requestsPerMinute: _requestTimestamps.length,
      maxRequestsPerMinute: _maxRequestsPerMinute,
    );
  }

  static Future<void> loadDailyStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson = prefs.getString('google_places_daily_stats');

      if (statsJson != null) {
        final stats = json.decode(statsJson);
        final savedDate = DateTime.parse(stats['date']);

        if (_isSameDay(savedDate, DateTime.now())) {
          _dailyRequestCount = stats['count'] as int;
          _totalCostToday = (stats['cost'] as num).toDouble();
          _lastResetDate = savedDate;

          debugPrint(
              '📊 Wczytano statystyki: $_dailyRequestCount zapytań, \$${_totalCostToday.toStringAsFixed(3)}');
        }
      }
    } catch (e) {
      debugPrint('Błąd wczytywania statystyk: $e');
    }
  }

  Future<void> _saveDailyStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stats = {
        'date': DateTime.now().toIso8601String(),
        'count': _dailyRequestCount,
        'cost': _totalCostToday,
      };
      await prefs.setString('google_places_daily_stats', json.encode(stats));
    } catch (e) {
      debugPrint('Błąd zapisywania statystyk: $e');
    }
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static Future<void> resetStatistics() async {
    _dailyRequestCount = 0;
    _totalCostToday = 0.0;
    _requestTimestamps.clear();
    _lastResetDate = DateTime.now();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('google_places_daily_stats');

    debugPrint('✅ Statystyki zresetowane');
  }
}
