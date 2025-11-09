import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DrawerMenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String route;

  const DrawerMenuItem({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title),
      onTap: () => context.push(route),
    );
  }
}
