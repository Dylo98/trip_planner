import 'package:flutter/material.dart';
import 'package:trip_planner/features/trip/model/trip_model.dart';
import 'package:trip_planner/features/trip/utils/trip_validators.dart';

class DateChangeResult {
  final DateTime startDate;

  final DateTime? endDate;

  DateChangeResult({
    required this.startDate,
    this.endDate,
  });
}

class DateChangeDialog extends StatefulWidget {
  const DateChangeDialog({
    super.key,
    required this.trip,
    required this.existingTrips,
  });

  final Trip trip;

  final List<Trip> existingTrips;

  @override
  State<DateChangeDialog> createState() => _DateChangeDialogState();
}

class _DateChangeDialogState extends State<DateChangeDialog> {
  late DateTime? _startDate;
  late DateTime? _endDate;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startDate = widget.trip.startDate;
    _endDate = widget.trip.endDate;
  }

  bool get _isOngoingTrip => widget.trip.tripType == TripType.ongoing;

  void _validateAndSubmit() {
    final validationError = TripValidators.validateTripDatesWithConflicts(
      startDate: _startDate,
      endDate: _endDate,
      existingTrips: widget.existingTrips,
      currentTripId: widget.trip.id,
    );

    if (validationError != null) {
      setState(() => _errorMessage = validationError);
      return;
    }

    if (_startDate == null) {
      setState(() => _errorMessage = 'Data rozpoczęcia jest wymagana');
      return;
    }

    Navigator.pop(
      context,
      DateChangeResult(
        startDate: _startDate!,
        endDate: _endDate,
      ),
    );
  }

  void _finishOngoingTrip() {
    setState(() {
      _endDate = DateTime.now();
      _errorMessage = null;
    });
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
        _errorMessage = null;
      });
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
        _errorMessage = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isOngoingTrip ? 'Zarządzaj podróżą' : 'Zmień daty podróży'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isOngoingTrip && _endDate == null) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _finishOngoingTrip,
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Zakończ podróż'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ustawi datę zakończenia na dzisiaj',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const Divider(height: 24),
            ],
            const Text(
              'Data rozpoczęcia',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _selectStartDate,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      _startDate != null
                          ? '${_startDate!.day.toString().padLeft(2, '0')}-${_startDate!.month.toString().padLeft(2, '0')}-${_startDate!.year}'
                          : 'Wybierz datę',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (!_isOngoingTrip || _endDate != null) ...[
              const Text(
                'Data zakończenia',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectEndDate,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _endDate != null
                            ? '${_endDate!.day.toString().padLeft(2, '0')}-${_endDate!.month.toString().padLeft(2, '0')}-${_endDate!.year}'
                            : 'Wybierz datę',
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Anuluj'),
        ),
        ElevatedButton(
          onPressed: _validateAndSubmit,
          child: const Text('Zapisz'),
        ),
      ],
    );
  }
}
