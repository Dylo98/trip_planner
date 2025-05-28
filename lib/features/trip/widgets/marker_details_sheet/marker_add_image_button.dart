import 'package:flutter/material.dart';

class AddImageButton extends StatelessWidget {
  const AddImageButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 8,
      top: 8,
      child: FloatingActionButton(
        mini: true,
        onPressed: onPressed,
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }
}
