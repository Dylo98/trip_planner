import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// NOTIFICATIONS (SNACKBARS)
import 'package:trip_planner/core/widgets/app_notifications.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  bool _tripReminders = true;
  bool _weeklyDigest = false;
  bool _pushNotifications = true;

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('notifications')
          .get();

      if (doc.exists && mounted) {
        final data = doc.data()!;
        setState(() {
          _tripReminders = data['tripReminders'] ?? true;
          _weeklyDigest = data['weeklyDigest'] ?? false;
          _pushNotifications = data['pushNotifications'] ?? true;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppNotifications.showError(
          context: context,
          message: 'Nie udało się wczytać ustawień powiadomień',
        );
      }
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception('Użytkownik niezalogowany');

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('notifications')
          .set({
        'tripReminders': _tripReminders,
        'weeklyDigest': _weeklyDigest,
        'pushNotifications': _pushNotifications,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
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
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Powiadomienia')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

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
      body: ListView(
        children: [
          _buildSectionHeader('Ogólne'),
          _buildSwitchTile(
            title: 'Wszystkie powiadomienia push',
            subtitle: 'Włącz/wyłącz wszystkie powiadomienia w aplikacji',
            value: _pushNotifications,
            icon: Icons.notifications_active,
            onChanged: (value) {
              setState(() => _pushNotifications = value);
              _saveSettings();
            },
          ),
          const Divider(height: 32),
          _buildSectionHeader('Podróże'),
          _buildSwitchTile(
            title: 'Przypomnienia o podróżach',
            subtitle: 'Powiadom mnie przed rozpoczęciem podróży',
            value: _tripReminders,
            icon: Icons.calendar_today,
            onChanged: (value) {
              setState(() => _tripReminders = value);
              _saveSettings();
            },
          ),
          _buildSwitchTile(
            title: 'Tygodniowe podsumowanie',
            subtitle: 'Otrzymuj cotygodniowe podsumowanie swoich podróży',
            value: _weeklyDigest,
            icon: Icons.summarize,
            onChanged: (value) {
              setState(() => _weeklyDigest = value);
              _saveSettings();
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
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required IconData icon,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
      secondary: Icon(icon, color: Colors.grey[700]),
    );
  }
}
