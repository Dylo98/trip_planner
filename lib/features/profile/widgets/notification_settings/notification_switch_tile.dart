import 'package:flutter/material.dart';

class NotificationSwitchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final IconData icon;
  final ValueChanged<bool> onChanged;

  const NotificationSwitchTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
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
