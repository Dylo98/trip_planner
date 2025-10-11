import 'package:flutter/material.dart';

// FIREBASE //
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// NAVIGATION //
import 'package:trip_planner/core/navigation/my_trips_navigation.dart';
import 'package:trip_planner/core/navigation/add_trip_navigation.dart';

// THEME //
import 'package:trip_planner/core/theme/colors.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  String _deriveName(User? user) {
    if (user?.displayName != null && user!.displayName!.trim().isNotEmpty) {
      return user.displayName!.trim();
    }
    final email = user?.email;
    if (email != null && email.contains('@')) {
      return email.split('@').first;
    }
    return 'Użytkownik';
  }

  @override
  Widget build(BuildContext context) {
    final authUser = FirebaseAuth.instance.currentUser;
    final uid = authUser?.uid;

    return Drawer(
      child: Column(
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(gradient: AppColors.primaryGradient),
            child: Center(child: Image.asset("assets/images/logo.png")),
          ),

          // ======== SEKCJA PROFILU ========
          if (uid != null)
            StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .snapshots(),
              builder: (context, snap) {
                // domyślne z Auth
                String name = _deriveName(authUser);
                String avatarUrl = authUser?.photoURL ?? '';

                // nadpisz danymi z Firestore (jeśli są)
                if (snap.hasData && snap.data!.exists) {
                  final data = snap.data!.data();
                  if (data != null) {
                    final n = (data['name'] as String?)?.trim();
                    final a = (data['avatar'] as String?)?.trim();
                    if (n != null && n.isNotEmpty) name = n;
                    if (a != null && a.isNotEmpty) avatarUrl = a;
                  }
                }

                final hasAvatar = avatarUrl.isNotEmpty;

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: hasAvatar
                            ? NetworkImage(avatarUrl)
                            : const AssetImage('assets/images/no_profile.png')
                                as ImageProvider,
                        child: hasAvatar
                            ? null
                            : const Icon(Icons.person,
                                color: Colors.grey, size: 30),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            )
          else
            const ListTile(
              leading: Icon(Icons.person_outline),
              title: Text('Nie zalogowano'),
              subtitle: Text('Zaloguj się, aby zobaczyć profil'),
            ),

          const SizedBox(height: 20),

          // ======== MENU ========
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.home, color: Colors.black),
                  title: const Text('Strona główna'),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.add, color: AppColors.primary),
                  title: const Text('Dodaj nową podróż'),
                  onTap: () => navigateToAddTrip(context),
                ),
                ListTile(
                  leading: const Icon(Icons.book, color: Colors.blue),
                  title: const Text('Moje podróże'),
                  onTap: () => navigateToMyTrips(context),
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
                  onTap: () => FirebaseAuth.instance.signOut(),
                ),
              ],
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text(
              'TripPlanner v1.0',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}
