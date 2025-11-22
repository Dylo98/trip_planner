import 'package:flutter/material.dart';

class ConfirmationDialogHelper {
  static Future<bool> showDeleteMarkerDialog(
    BuildContext context,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Usuń punkt podróży'),
        content: const Text('Czy na pewno chcesz usunąć ten punkt podróży?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Anuluj'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Usuń'),
          ),
        ],
      ),
    );

    return confirmed ?? false;
  }

  static Future<bool> showDeleteTripDialog(
    BuildContext context,
    String tripName,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Usuń podróż'),
        content: Text(
          'Czy na pewno chcesz usunąć podróż "$tripName"?\n\n'
          'Ta akcja jest nieodwracalna i usunie wszystkie zdjęcia, markery i dane podróży.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Anuluj'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Usuń'),
          ),
        ],
      ),
    );

    return confirmed ?? false;
  }
}
