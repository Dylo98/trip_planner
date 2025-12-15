import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/features/profile/model/notification_settings_model.dart';
import 'package:trip_planner/features/profile/services/notification_settings_service.dart';

final notificationSettingsServiceProvider =
    Provider<NotificationSettingsService>((ref) {
  return NotificationSettingsService();
});

final notificationSettingsProvider =
    FutureProvider<NotificationSettings>((ref) async {
  final service = ref.watch(notificationSettingsServiceProvider);
  return service.getNotificationSettings();
});
