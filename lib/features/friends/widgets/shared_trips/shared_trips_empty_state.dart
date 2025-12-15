import 'package:flutter/material.dart';
import 'package:trip_planner/core/widgets/empty_state.dart';

class SharedTripsEmptyState extends StatelessWidget {
  const SharedTripsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      icon: Icons.share_outlined,
      title: 'Brak współdzielonych podróży',
      subtitle: 'Tutaj zobaczysz podróże,\nktóre znajomi udostępnili Ci',
    );
  }
}
