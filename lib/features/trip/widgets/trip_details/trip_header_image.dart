import 'package:flutter/material.dart';

class TripHeaderImage extends StatelessWidget {
  const TripHeaderImage({
    super.key,
    required this.imageUrl,
  });

  final String? imageUrl;

  bool get _isValidUrl =>
      imageUrl != null &&
      imageUrl!.isNotEmpty &&
      Uri.tryParse(imageUrl!)?.hasAbsolutePath == true;

  @override
  Widget build(BuildContext context) {
    if (_isValidUrl) {
      return Image.network(
        imageUrl!,
        width: double.infinity,
        height: 200,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      height: 200,
      color: Colors.grey[300],
      alignment: Alignment.center,
      child: const Text(
        'Brak zdjęcia',
        style: TextStyle(
          color: Colors.black54,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
