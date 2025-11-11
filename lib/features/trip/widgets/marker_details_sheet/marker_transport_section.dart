// lib/features/trip/widgets/marker_details_sheet/marker_transport_section.dart
import 'package:flutter/material.dart';
import 'package:trip_planner/features/trip/widgets/select_transport.dart';

class MarkerTransportSection extends StatelessWidget {
  const MarkerTransportSection({
    super.key,
    required this.transportMode,
    required this.onTransportChanged,
  });

  final String? transportMode;
  final Function(String) onTransportChanged;

  IconData _getTransportIcon(String? mode) {
    switch (mode) {
      case 'plane':
        return Icons.flight;
      case 'walk':
        return Icons.directions_walk;
      case 'car':
        return Icons.directions_car;
      default:
        return Icons.directions_bus;
    }
  }

  String _getTransportName(String? mode) {
    switch (mode) {
      case 'plane':
        return 'Samolot';
      case 'walk':
        return 'Pieszo';
      case 'car':
        return 'Samochód';
      default:
        return 'Inne';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Transport',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ListTile(
          leading: Icon(_getTransportIcon(transportMode)),
          title: Text(_getTransportName(transportMode)),
          trailing: const Icon(Icons.edit),
          onTap: () async {
            final newMode = await selectTransport(context);
            if (newMode != null) {
              onTransportChanged(newMode);
            }
          },
        ),
      ],
    );
  }
}
