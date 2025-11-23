import 'package:flutter/material.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trip_planner/features/home/screens/home.dart';
import 'package:trip_planner/features/auth/screens/auth.dart';
import 'package:trip_planner/features/profile/screens/change_password.dart';
import 'package:trip_planner/features/profile/screens/edit_profile.dart';
import 'package:trip_planner/features/profile/screens/notification_settings.dart';
import 'package:trip_planner/features/profile/screens/profile.dart';
import 'package:trip_planner/features/trip/screens/new_trip/new_trip_screen.dart';
import 'package:trip_planner/features/trip/screens/trip_list/trips_list_screen.dart';
import 'package:trip_planner/features/friends/screens/friends_screen.dart';
import 'package:trip_planner/features/statistics/screens/statistics_screen.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final user = FirebaseAuth.instance.currentUser;
    final isAuthScreen = state.matchedLocation == '/auth';

    if (user == null && !isAuthScreen) {
      return '/auth';
    }

    if (user != null && isAuthScreen) {
      return '/';
    }

    return null;
  },
  refreshListenable: GoRouterRefreshStream(
    FirebaseAuth.instance.authStateChanges(),
  ),
  routes: [
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/add-trip',
      builder: (context, state) => const NewTripScreen(),
    ),
    GoRoute(
      path: '/my-trips',
      builder: (context, state) => const MyTripsScreen(),
    ),
    GoRoute(
      path: '/friends',
      builder: (context, state) => const FriendsScreen(),
    ),
    GoRoute(
      path: '/statistics',
      builder: (context, state) => const StatisticsScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
      routes: [
        GoRoute(
          path: 'edit',
          builder: (context, state) => const EditProfileScreen(),
        ),
        GoRoute(
          path: 'change-password',
          builder: (context, state) => const ChangePasswordScreen(),
        ),
        GoRoute(
          path: 'notifications',
          builder: (context, state) => const NotificationSettingsScreen(),
        ),
      ],
    ),
  ],
);
