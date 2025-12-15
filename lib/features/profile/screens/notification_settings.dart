import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/core/widgets/app_notifications.dart';
import 'package:trip_planner/core/widgets/loading_indicator.dart';
import 'package:trip_planner/core/widgets/error_display.dart';
import 'package:trip_planner/features/profile/providers/notification_settings_provider.dart';
import 'package:trip_planner/features/profile/model/notification_settings_model.dart';
import 'package:trip_planner/features/profile/widgets/notification_settings/notification_section_header.dart';
import 'package:trip_planner/features/profile/widgets/notification_settings/notification_switch_tile.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  NotificationSettings? _settings;
  bool _isSaving = false;

  Future<void> _updateSetting(NotificationSettings newSettings) async {
    setState(() {
      _settings = newSettings;
      _isSaving = true;
    });

    try {
      final service = ref.read(notificationSettingsServiceProvider);
      await service.updateNotificationSettings(newSettings);

      if (mounted) {
        ref.invalidate(notificationSettingsProvider);
        AppNotifications.showSuccess(
          context: context,
          message: 'Ustawienia powiadomień zostały zapisane',
        );
      }
    } catch (e) {
      if (mounted) {
        AppNotifications.showError(
          context: context,
          message: 'Błąd podczas zapisywania ustawień',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(notificationSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Powiadomienia'),
        elevation: 0,
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: settingsAsync.when(
        data: (settings) {
          final currentSettings = _settings ?? settings;

          return ListView(
            children: [
              const NotificationSectionHeader(title: 'Ogólne'),
              NotificationSwitchTile(
                title: 'Wszystkie powiadomienia push',
                subtitle: 'Włącz/wyłącz wszystkie powiadomienia w aplikacji',
                value: currentSettings.pushNotifications,
                icon: Icons.notifications_active,
                onChanged: (value) {
                  _updateSetting(
                    currentSettings.copyWith(pushNotifications: value),
                  );
                },
              ),
              const Divider(height: 32),
              const NotificationSectionHeader(title: 'Podróże'),
              NotificationSwitchTile(
                title: 'Przypomnienia o podróżach',
                subtitle: 'Powiadom mnie przed rozpoczęciem podróży',
                value: currentSettings.tripReminders,
                icon: Icons.calendar_today,
                onChanged: (value) {
                  _updateSetting(
                    currentSettings.copyWith(tripReminders: value),
                  );
                },
              ),
              NotificationSwitchTile(
                title: 'Tygodniowe podsumowanie',
                subtitle: 'Otrzymuj cotygodniowe podsumowanie swoich podróży',
                value: currentSettings.weeklyDigest,
                icon: Icons.summarize,
                onChanged: (value) {
                  _updateSetting(
                    currentSettings.copyWith(weeklyDigest: value),
                  );
                },
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Zmiany są zapisywane automatycznie',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );
        },
        loading: () => const LoadingIndicator(),
        error: (err, stack) => ErrorDisplay(
          message: 'Nie udało się wczytać ustawień powiadomień',
          onRetry: () => ref.invalidate(notificationSettingsProvider),
        ),
      ),
    );
  }
}
