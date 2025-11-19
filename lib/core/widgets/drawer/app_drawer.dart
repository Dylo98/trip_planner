import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trip_planner/core/theme/colors.dart';
import 'package:trip_planner/core/widgets/drawer/drawer_logout_item.dart';
import 'package:trip_planner/core/widgets/drawer/drawer_menu_item.dart';
import 'package:trip_planner/features/friends/controller/friends_provider.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingCountAsync = ref.watch(pendingRequestsCountProvider);

    return Drawer(
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            // ⬅️ PRZEKAZUJESZ context
            child: _buildMenuItems(context, pendingCountAsync),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return DrawerHeader(
      decoration: BoxDecoration(gradient: AppColors.primaryGradient),
      child: Center(
        child: Image.asset("assets/images/logo.png"),
      ),
    );
  }

  // ⬅️ DODAJEMY BuildContext context
  Widget _buildMenuItems(
    BuildContext context,
    AsyncValue<int> pendingCountAsync,
  ) {
    final pendingCount = pendingCountAsync.value ?? 0;

    return ListView(
      children: [
        const DrawerMenuItem(
          icon: Icons.home,
          iconColor: Colors.black,
          title: 'Strona główna',
          route: '/',
        ),
        const DrawerMenuItem(
          icon: Icons.add,
          iconColor: AppColors.primary,
          title: 'Dodaj nową podróż',
          route: '/add-trip',
        ),
        const DrawerMenuItem(
          icon: Icons.book,
          iconColor: Colors.blue,
          title: 'Moje podróże',
          route: '/my-trips',
        ),
        ListTile(
          leading: Badge(
            label: pendingCount > 0 ? Text('$pendingCount') : null,
            isLabelVisible: pendingCount > 0,
            child: const Icon(Icons.people, color: Colors.purple),
          ),
          title: const Text('Znajomi'),
          onTap: () {
            // zamknij drawer
            Navigator.pop(context);
            // i nawiguj do /friends
            context.push('/friends');
          },
        ),
        const DrawerMenuItem(
          icon: Icons.bar_chart,
          iconColor: Colors.deepOrange,
          title: 'Statystyki',
          route: '/statistics',
        ),
        const DrawerMenuItem(
          icon: Icons.person,
          iconColor: Colors.pink,
          title: 'Profil',
          route: '/profile',
        ),
        const DrawerLogoutItem(),
      ],
    );
  }

  Widget _buildFooter() {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(),
        Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: Text(
            'TripPlanner v1.0.0',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ),
      ],
    );
  }
}
