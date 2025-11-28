import 'package:flutter/material.dart';
import 'package:trip_planner/core/theme/colors.dart';
import 'package:trip_planner/core/theme/text_style.dart';

class TripHeaderImage extends StatelessWidget {
  const TripHeaderImage({
    super.key,
    required this.imageUrl,
    this.onEditPressed,
    this.onRemovePressed,
    this.isEditable = false,
  });

  final String? imageUrl;
  final VoidCallback? onEditPressed;
  final VoidCallback? onRemovePressed;
  final bool isEditable;

  bool get _isValidUrl =>
      imageUrl != null &&
      imageUrl!.isNotEmpty &&
      Uri.tryParse(imageUrl!)?.hasAbsolutePath == true;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (_isValidUrl)
          Image.network(
            imageUrl!,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
          )
        else
          _buildPlaceholder(),
        if (isEditable)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        if (isEditable)
          Positioned(
            top: 8,
            right: 8,
            child: Row(
              children: [
                _EditButton(
                  icon: _isValidUrl ? Icons.edit : Icons.add_photo_alternate,
                  tooltip: _isValidUrl ? 'Zmień zdjęcie' : 'Dodaj zdjęcie',
                  onPressed: onEditPressed,
                ),
                if (_isValidUrl && onRemovePressed != null) ...[
                  const SizedBox(width: 8),
                  _EditButton(
                    icon: Icons.delete,
                    tooltip: 'Usuń zdjęcie',
                    onPressed: onRemovePressed,
                    backgroundColor: AppColors.red,
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      height: 200,
      color: Colors.grey[200],
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.landscape,
            size: 48,
            color: AppColors.grey,
          ),
          const SizedBox(height: 8),
          Text(
            'Brak zdjęcia',
            style: AppTextStyles.bodyTextSecondary,
          ),
          if (isEditable && onEditPressed != null) ...[],
        ],
      ),
    );
  }
}

class _EditButton extends StatelessWidget {
  const _EditButton({
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.backgroundColor,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:
                  (backgroundColor ?? AppColors.black).withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: AppColors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
