import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'google_places_models.dart';

class GooglePlacesRateLimiter {
  static const int _maxRequestsPerMinute = 60;
  static const int _maxRequestsPerDay = 2000;

  static const double costNearbySearch = 0.032;
  static const double costPlaceDetails = 0.008;
  static const double costPhoto = 0.0;

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
      return true;
    }

    final oneMinuteAgo = now.subtract(const Duration(minutes: 1));
    _requestTimestamps.removeWhere((ts) => ts.isBefore(oneMinuteAgo));

    if (_requestTimestamps.length >= _maxRequestsPerMinute) {
      return false;
    }

    return true;
  }

  void recordRequest(double cost) {
    _requestTimestamps.add(DateTime.now());
    _dailyRequestCount++;
    _totalCostToday += cost;
    _saveDailyStats();
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
        } else {
          _dailyRequestCount = 0;
          _totalCostToday = 0.0;
          _lastResetDate = DateTime.now();
        }
      }
    } catch (e) {
      _dailyRequestCount = 0;
      _totalCostToday = 0.0;
      _lastResetDate = DateTime.now();
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
//
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
  }
}
