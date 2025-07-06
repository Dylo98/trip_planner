import 'package:flutter/material.dart';

Future<String?> selectTransport(BuildContext context) async {
  return await showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Wybierz środek transportu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.flight),
              title: const Text('Samolot'),
              onTap: () => Navigator.pop(context, 'plane'),
            ),
            ListTile(
              leading: Icon(Icons.directions_walk),
              title: const Text('Pieszo'),
              onTap: () => Navigator.pop(context, 'walk'),
            ),
            ListTile(
              leading: Icon(Icons.directions_car),
              title: const Text('Samochód'),
              onTap: () => Navigator.pop(context, 'car'),
            ),
            ListTile(
              leading: Icon(Icons.directions_bus),
              title: const Text('Inne'),
              onTap: () => Navigator.pop(context, 'other'),
            ),
          ],
        ),
      );
    },
  );
}
