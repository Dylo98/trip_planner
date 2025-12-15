class NotificationSettings {
  final bool tripReminders;
  final bool weeklyDigest;
  final bool pushNotifications;

  const NotificationSettings({
    this.tripReminders = true,
    this.weeklyDigest = false,
    this.pushNotifications = true,
  });

  factory NotificationSettings.fromMap(Map<String, dynamic> map) {
    return NotificationSettings(
      tripReminders: map['tripReminders'] ?? true,
      weeklyDigest: map['weeklyDigest'] ?? false,
      pushNotifications: map['pushNotifications'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tripReminders': tripReminders,
      'weeklyDigest': weeklyDigest,
      'pushNotifications': pushNotifications,
    };
  }

  NotificationSettings copyWith({
    bool? tripReminders,
    bool? weeklyDigest,
    bool? pushNotifications,
  }) {
    return NotificationSettings(
      tripReminders: tripReminders ?? this.tripReminders,
      weeklyDigest: weeklyDigest ?? this.weeklyDigest,
      pushNotifications: pushNotifications ?? this.pushNotifications,
    );
  }
}
