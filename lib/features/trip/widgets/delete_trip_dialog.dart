import 'package:flutter/material.dart';

class DeleteTripDialog extends StatelessWidget {
  const DeleteTripDialog({
    super.key,
    required this.tripName,
  });

  final String tripName;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
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
    );
  }
}
