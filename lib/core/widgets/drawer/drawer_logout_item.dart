import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/core/theme/colors.dart';

class DrawerLogoutItem extends ConsumerWidget {
  const DrawerLogoutItem({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(Icons.exit_to_app, color: AppColors.red),
      title: const Text('Wyloguj się'),
      onTap: () => _handleLogout(context),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    Navigator.of(context).pop();
    await FirebaseAuth.instance.signOut();
  }
}
