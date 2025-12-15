import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import 'package:trip_planner/features/profile/widgets/profile_menu/profile_menu_item.dart';

class ProfileMenu extends StatelessWidget {
  final VoidCallback onLogoutTap;

  const ProfileMenu({
    super.key,
    required this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(),
        ProfileMenuItem(
          icon: Icons.person_outline,
          title: 'Edytuj profil',
          onTap: () => context.push('/profile/edit'),
        ),
        ProfileMenuItem(
          icon: Icons.security_outlined,
          title: 'Prywatność i bezpieczeństwo',
          onTap: () => context.push('/profile/change-password'),
        ),
        const Divider(height: 30),
        ProfileMenuItem(
          icon: Icons.logout,
          title: 'Wyloguj się',
          textColor: Colors.red,
          onTap: onLogoutTap,
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
