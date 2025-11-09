import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/core/theme/colors.dart';
import 'package:trip_planner/core/widgets/drawer/drawer_logout_item.dart';
import 'package:trip_planner/core/widgets/drawer/drawer_menu_item.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
        child: Column(
      children: [
        _buildHeader(),
        Expanded(child: _buildMenuItems()),
        _buildFooter(),
      ],
    ));
  }

  Widget _buildHeader() {
    return DrawerHeader(
      decoration: BoxDecoration(gradient: AppColors.primaryGradient),
      child: Center(
        child: Image.asset("assets/images/logo.png"),
      ),
    );
  }

  Widget _buildMenuItems() {
    return ListView(
      children: const [
        DrawerMenuItem(
            icon: Icons.home,
            iconColor: Colors.black,
            title: 'Strona główna',
            route: '/'),
        DrawerMenuItem(
            icon: Icons.add,
            iconColor: AppColors.primary,
            title: 'Dodaj nową podróż',
            route: '/add-trip'),
        DrawerMenuItem(
            icon: Icons.book,
            iconColor: Colors.blue,
            title: 'Moje podróże',
            route: '/my-trips'),
        DrawerMenuItem(
            icon: Icons.person,
            iconColor: Colors.pink,
            title: 'Profil',
            route: '/profile'),
        DrawerLogoutItem(),
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
            )),
      ],
    );
  }
}
