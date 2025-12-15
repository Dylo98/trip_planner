import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trip_planner/core/utils/validators.dart';
import 'package:trip_planner/core/widgets/app_notifications.dart';
import 'package:trip_planner/core/widgets/dialog/dialog_confirmation.dart';
import 'package:trip_planner/features/auth/providers/user_provider.dart';
import 'package:trip_planner/features/trip/model/trip_model.dart';
import 'package:trip_planner/features/trip/services/trip_service.dart';

class TripDetailsEditController {
  final WidgetRef ref;
  final BuildContext context;
  final Trip trip;

  TripDetailsEditController({
    required this.ref,
    required this.context,
    required this.trip,
  });

  TripService get _tripService => ref.read(tripServiceProvider);

  Future<bool> handlePhotoChange() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image == null) {
        return false;
      }

      if (!context.mounted) return false;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      try {
        final File imageFile = File(image.path);
        final String photoUrl = await _tripService.uploadTripImage(
          imageFile,
          trip.id,
        );

        await _tripService.updateTripPhoto(trip.id, photoUrl);

        if (context.mounted) {
          Navigator.pop(context);
          AppNotifications.showSuccess(
            context: context,
            message: 'Zdjęcie zostało dodane',
          );
          return true;
        }

        return false;
      } catch (e) {
        if (context.mounted) {
          Navigator.pop(context);
          AppNotifications.showError(
            context: context,
            message: 'Nie udało się dodać zdjęcia. Spróbuj ponownie.',
          );
        }

        return false;
      }
    } catch (e) {
      if (context.mounted) {
        AppNotifications.showError(
          context: context,
          message: 'Nie udało się wybrać zdjęcia',
        );
      }

      return false;
    }
  }

  Future<bool> handlePhotoRemoval() async {
    final confirmed = await ConfirmationDialogs.deletePhoto(
      context: context,
    );

    if (!confirmed || !context.mounted) return false;

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      await _tripService.updateTripPhoto(trip.id, null);

      if (context.mounted) {
        Navigator.pop(context);
        AppNotifications.showSuccess(
          context: context,
          message: 'Zdjęcie zostało usunięte',
        );
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        AppNotifications.showError(
          context: context,
          message: 'Nie udało się usunąć zdjęcia. Spróbuj ponownie.',
        );
      }
      return false;
    }
  }

  Future<bool> handleDateChange() async {
    try {
      final userAsync = ref.read(authStateProvider);
      final user = userAsync.value;

      if (user == null) {
        AppNotifications.showError(
          context: context,
          message: 'Nie jesteś zalogowany',
        );
        return false;
      }

      final allTripsStream = _tripService.getTrips(user.uid);
      final allTrips = await allTripsStream.first;

      if (!context.mounted) return false;

      final result = await showDialog<DateChangeResult>(
        context: context,
        builder: (context) => DateChangeDialog(
          trip: trip,
          existingTrips: allTrips,
        ),
      );

      if (result == null || !context.mounted) return false;

      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );
        await _tripService.updateTripDates(
          trip.id,
          result.startDate,
          result.endDate,
        );

        if (context.mounted) {
          Navigator.pop(context);
          AppNotifications.showSuccess(
            context: context,
            message: 'Daty zostały zaktualizowane',
          );
          return true;
        }

        return false;
      } catch (e) {
        if (context.mounted) {
          Navigator.pop(context);
          AppNotifications.showError(
            context: context,
            message: 'Nie udało się zaktualizować dat. Spróbuj ponownie.',
          );
        }
        return false;
      }
    } catch (e) {
      if (context.mounted) {
        AppNotifications.showError(
          context: context,
          message: 'Wystąpił nieoczekiwany błąd',
        );
      }
      return false;
    }
  }

  Future<bool> handleNameChange() async {
    final TextEditingController nameController = TextEditingController(
      text: trip.name,
    );

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Zmień nazwę podróży'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Nazwa podróży',
            hintText: 'Wpisz nową nazwę',
          ),
          maxLength: 40,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Anuluj'),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = nameController.text.trim();
              if (newName.isEmpty) {
                AppNotifications.showError(
                  context: context,
                  message: 'Nazwa nie może być pusta',
                );
                return;
              }
              if (newName.length < 3) {
                AppNotifications.showError(
                  context: context,
                  message: 'Nazwa musi mieć min. 3 znaki',
                );
                return;
              }
              Navigator.pop(context, newName);
            },
            child: const Text('Zapisz'),
          ),
        ],
      ),
    );

    if (result == null || !context.mounted) return false;

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      await _tripService.updateTripName(trip.id, result);

      if (context.mounted) {
        Navigator.pop(context);
        AppNotifications.showSuccess(
          context: context,
          message: 'Nazwa została zmieniona',
        );
        return true;
      }

      return false;
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        AppNotifications.showError(
          context: context,
          message: 'Nie udało się zmienić nazwy. Spróbuj ponownie.',
        );
      }
      return false;
    }
  }
}

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
    final validationError = Validators.validateTripDatesWithConflicts(
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
