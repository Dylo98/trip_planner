import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trip_planner/core/utils/validators.dart';
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
          _showSuccessMessage('Zdjęcie zostało dodane!');
          return true;
        }

        return false;
      } catch (e) {
        if (context.mounted) {
          Navigator.pop(context);
        }
        String errorMessage;

        if (e.toString().contains('not-found')) {
          errorMessage =
              'Nie znaleziono podróży w bazie.\nID: ${trip.id}\n\nSprawdź czy podróż istnieje w Firestore.';
        } else if (e.toString().contains('permission-denied')) {
          errorMessage =
              'Brak uprawnień do edycji.\nSprawdź Firebase Security Rules.';
        } else if (e.toString().contains('network')) {
          errorMessage = 'Brak połączenia z internetem';
        } else {
          errorMessage = 'Błąd: ${e.toString()}';
        }

        if (context.mounted) {
          _showErrorMessage(errorMessage);
        }

        return false;
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorMessage('Nieoczekiwany błąd: ${e.toString()}');
      }

      return false;
    }
  }

  Future<bool> handlePhotoRemoval() async {
    final confirmed = await _showConfirmationDialog(
      title: 'Usuń zdjęcie',
      content: 'Czy na pewno chcesz usunąć zdjęcie główne podróży?',
    );

    if (!confirmed) return false;

    try {
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }
      await _tripService.updateTripPhoto(trip.id, null);

      if (context.mounted) {
        Navigator.pop(context);
        _showSuccessMessage('Zdjęcie zostało usunięte');
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        _showErrorMessage('Błąd podczas usuwania zdjęcia');
      }
      return false;
    }
  }

  Future<bool> handleDateChange() async {
    try {
      final userAsync = ref.read(authStateProvider);
      final user = userAsync.value;

      if (user == null) {
        _showErrorMessage('Nie jesteś zalogowany');
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
          _showSuccessMessage('Daty zostały zaktualizowane');
          return true;
        }

        return false;
      } catch (e) {
        if (context.mounted) {
          Navigator.pop(context);
          _showErrorMessage('Błąd podczas aktualizacji dat');
        }
        return false;
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorMessage('Błąd: ${e.toString()}');
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Nazwa nie może być pusta'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              if (newName.length < 3) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Nazwa musi mieć min. 3 znaki'),
                    backgroundColor: Colors.red,
                  ),
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
        _showSuccessMessage('Nazwa została zmieniona');
        return true;
      }

      return false;
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        _showErrorMessage('Błąd podczas zmiany nazwy');
      }
      return false;
    }
  }

  Future<bool> _showConfirmationDialog({
    required String title,
    required String content,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Anuluj'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Potwierdź'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                maxLines: 5,
                overflow: TextOverflow.visible,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
      ),
    );
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
