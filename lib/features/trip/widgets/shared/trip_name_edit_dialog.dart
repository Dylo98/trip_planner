import 'package:flutter/material.dart';
import 'package:trip_planner/core/widgets/app_notifications.dart';

class TripNameEditDialog extends StatelessWidget {
  const TripNameEditDialog({
    super.key,
    required this.currentName,
  });

  final String currentName;

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController(
      text: currentName,
    );

    return AlertDialog(
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
    );
  }

  static Future<String?> show({
    required BuildContext context,
    required String currentName,
  }) async {
    return showDialog<String>(
      context: context,
      builder: (context) => TripNameEditDialog(
        currentName: currentName,
      ),
    );
  }
}
