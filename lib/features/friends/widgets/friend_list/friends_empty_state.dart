import 'package:flutter/material.dart';
import 'package:trip_planner/core/widgets/empty_state.dart';

class FriendsEmptyState extends StatelessWidget {
  const FriendsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      icon: Icons.people_outline,
      title: 'Nie masz jeszcze znajomych',
      subtitle: 'Dodaj znajomych, aby dzielić się podróżami',
    );
  }
}
