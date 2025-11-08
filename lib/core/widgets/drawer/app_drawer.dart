import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// FIREBASE //
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

// NAVIGATION //

// THEME //
import 'package:trip_planner/core/theme/colors.dart';

// USER //
import 'package:trip_planner/features/auth/controller/user_provider.dart';

class AppDrawer extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final authUser = FirebaseAuth.instance.currentUser;
    final uid = authUser?.uid;
    final meAsync = ref.watch(meProvider);

    return Drawer(
      child: Column(
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(gradient: AppColors.primaryGradient),
            child: Center(child: Image.asset("assets/images/logo.png")),
          ),
          if (uid != null)
            meAsync.when(
              data: (me) {
                final name = (me?.name?.isNotEmpty == true)
                    ? me!.name!
                    : _deriveName(authUser);

                final avatarUrl = (me?.avatar?.isNotEmpty == true)
                    ? me!.avatar!
                    : (authUser?.photoURL ?? '');

                final hasAvatar = avatarUrl.isNotEmpty;

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage:
                            hasAvatar ? NetworkImage(avatarUrl) : null,
                        child: hasAvatar
                            ? null
                            : const Icon(
                                Icons.person,
                                color: Colors.white70,
                                size: 30,
                              ),
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
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              error: (_, __) => const ListTile(
                leading: Icon(Icons.person_outline),
                title: Text('Profil'),
                subtitle: Text('Błąd wczytywania'),
              ),
            )
          else
            const ListTile(
              leading: Icon(Icons.person_outline),
              title: Text('Nie zalogowano'),
              subtitle: Text('Zaloguj się, aby zobaczyć profil'),
            ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.home, color: Colors.black),
                  title: const Text('Strona główna'),
                  onTap: () => context.push('/'),
                ),
                ListTile(
                  leading: const Icon(Icons.add, color: AppColors.primary),
                  title: const Text('Dodaj nową podróż'),
                  onTap: () => context.push('/add-trip'),
                ),
                ListTile(
                  leading: const Icon(Icons.book, color: Colors.blue),
                  title: const Text('Moje podróże'),
                  onTap: () => context.push('/my-trips'),
                ),
                ListTile(
                  leading: const Icon(Icons.person, color: Colors.pink),
                  title: const Text('Profil'),
                  onTap: () => context.push('/profile'),
                ),
                ListTile(
                  leading: const Icon(Icons.exit_to_app, color: AppColors.red),
                  title: const Text('Wyloguj się'),
                  onTap: () async {
                    Navigator.of(context).pop();
                    await FirebaseAuth.instance.signOut();
                  },
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
