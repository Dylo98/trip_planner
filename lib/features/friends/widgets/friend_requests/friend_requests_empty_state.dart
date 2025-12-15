import 'package:flutter/material.dart';
import 'package:trip_planner/core/widgets/empty_state.dart';

class FriendRequestsEmptyState extends StatelessWidget {
  const FriendRequestsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      icon: Icons.mail_outline,
      title: 'Brak zaproszeń',
      subtitle: 'Tutaj zobaczysz zaproszenia do znajomych',
    );
  }
}
