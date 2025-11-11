// lib/features/trip/widgets/marker_details_sheet/marker_dates_section.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trip_planner/features/trip/widgets/marker_details_sheet/marker_details_state.dart';

class MarkerDatesSection extends StatelessWidget {
  const MarkerDatesSection({
    super.key,
    required this.state,
    required this.onDatesUpdated,
  });

  final MarkerDetailsState state;
  final VoidCallback onDatesUpdated;

  String _formatDT(DateTime? dt) {
    if (dt == null) return 'Nie ustawiono';
    return DateFormat('dd.MM.yyyy HH:mm').format(dt.toLocal());
  }

  Future<DateTime?> _pickDateTime(
      BuildContext context, DateTime? initial) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate == null) return null;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial ?? DateTime.now()),
    );
    if (pickedTime == null) return null;

    return DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Daty',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.flight_land),
          title: const Text('Przyjazd'),
          subtitle: Text(_formatDT(state.arrivalDateTime)),
          trailing: const Icon(Icons.edit),
          onTap: () async {
            final newDT = await _pickDateTime(context, state.arrivalDateTime);
            if (newDT == null) return;

            final departure = state.departureDateTime ?? newDT;
            await state.updateMarkerDates(
              arrival: newDT,
              departure: departure,
              setState: (fn) => onDatesUpdated(),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.flight_takeoff),
          title: const Text('Wyjazd'),
          subtitle: Text(_formatDT(state.departureDateTime)),
          trailing: const Icon(Icons.edit),
          onTap: () async {
            final newDT = await _pickDateTime(context, state.departureDateTime);
            if (newDT == null) return;

            final arrival = state.arrivalDateTime ?? newDT;
            await state.updateMarkerDates(
              arrival: arrival,
              departure: newDT,
              setState: (fn) => onDatesUpdated(),
            );
          },
        ),
      ],
    );
  }
}
