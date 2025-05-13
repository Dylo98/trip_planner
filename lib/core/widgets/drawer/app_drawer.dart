import 'package:flutter/material.dart';

// THEME //
import 'package:trip_planner/core/theme/colors.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            child: Center(
              child: Image.asset(
                "assets/images/logo.png",
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Colors.black),
            title: const Text('Strona główna'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.add, color: AppColors.primary),
            title: const Text('Dodaj nową podróż'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.book, color: Colors.blue),
            title: const Text('Moje podróże'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.pink),
            title: const Text('Profil'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.grey),
            title: const Text('Ustawienia'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: AppColors.red),
            title: const Text('Wyloguj się'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
