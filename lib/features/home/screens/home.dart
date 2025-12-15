import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trip_planner/core/theme/colors.dart';
import 'package:trip_planner/core/widgets/drawer/app_drawer.dart';
import 'package:trip_planner/core/widgets/empty_state.dart';
import 'package:trip_planner/core/widgets/loading_indicator.dart';
import 'package:trip_planner/core/widgets/app_notifications.dart';
import 'package:trip_planner/features/home/widgets/home_top.dart';
import 'package:trip_planner/features/home/widgets/home_content.dart';
import 'package:trip_planner/features/home/widgets/add_trip_box.dart';
import 'package:trip_planner/features/home/widgets/home_carousel.dart';
import 'package:trip_planner/features/home/widgets/home_empty_carousel.dart';
import 'package:trip_planner/features/trip/providers/get_trip_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userTripsAsync = ref.watch(getTripProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('TripPlanner'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
      ),
      drawer: const AppDrawer(),
      body: userTripsAsync.when(
        data: (userTrips) => ListView(
          children: <Widget>[
            const HomeTop(),
            const SizedBox(height: 20),
            const HomeContent(),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => context.push('/add-trip'),
              child: const AddTripBox(),
            ),
            const SizedBox(height: 20),
            userTrips.isNotEmpty
                ? HomeCarousel(userTrips: userTrips.take(3).toList())
                : const HomeEmptyCarousel(),
          ],
        ),
        loading: () => const LoadingIndicator(
          message: 'Ładowanie podróży...',
        ),
        error: (err, stack) => EmptyState(
          icon: Icons.error_outline,
          title: 'Nie udało się załadować podróży',
          subtitle: 'Sprawdź połączenie i spróbuj ponownie.',
          actionLabel: 'Spróbuj ponownie',
          action: () {
            AppNotifications.showError(
              context: context,
              message: 'Błąd ładowania. Odświeżam...',
            );
            ref.refresh(getTripProvider);
          },
        ),
      ),
    );
  }
}
