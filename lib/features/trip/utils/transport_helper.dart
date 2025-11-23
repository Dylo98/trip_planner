import 'package:flutter/material.dart';

class TransportHelper {
  static String getName(String? mode) {
    return switch (mode) {
      'plane' => 'Samolot',
      'walk' => 'Pieszo',
      'car' => 'Samochód',
      _ => 'Inne',
    };
  }

  static IconData getIcon(String? mode) {
    return switch (mode) {
      'plane' => Icons.flight,
      'walk' => Icons.directions_walk,
      'car' => Icons.directions_car,
      _ => Icons.directions_bus,
    };
  }

  static Color getColor(String? mode) {
    return switch (mode) {
      'plane' => Colors.blue,
      'walk' => Colors.green,
      'car' => Colors.orange,
      _ => Colors.grey,
    };
  }

  static const List<String> allModes = ['plane', 'walk', 'car', 'other'];

  static Future<String?> selectTransport(BuildContext context) async {
    return await showDialog<String>(
      context: context,
      builder: (context) => const _TransportSelectionDialog(),
    );
  }
}

class _TransportSelectionDialog extends StatelessWidget {
  const _TransportSelectionDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Wybierz środek transportu'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTransportOption(
            context,
            mode: 'plane',
            label: 'Samolot',
          ),
          _buildTransportOption(
            context,
            mode: 'walk',
            label: 'Pieszo',
          ),
          _buildTransportOption(
            context,
            mode: 'car',
            label: 'Samochód',
          ),
          _buildTransportOption(
            context,
            mode: 'other',
            label: 'Inne',
          ),
        ],
      ),
    );
  }

  Widget _buildTransportOption(
    BuildContext context, {
    required String mode,
    required String label,
  }) {
    return ListTile(
      leading: Icon(TransportHelper.getIcon(mode)),
      title: Text(label),
      onTap: () => Navigator.pop(context, mode),
    );
  }
}
