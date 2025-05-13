import 'package:flutter/material.dart';

// THEME //
import 'package:trip_planner/core/theme/colors.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            child: Center(
              child: Image.asset("assets/images/logo.png"),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        backgroundImage:
                            NetworkImage('https://i.pravatar.cc/150?img=5'),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Username'),
                          const Text('Liczba odwiedzonych krajów TODO')
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 20),
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
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text(
              'TripPlanner v1.0',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
