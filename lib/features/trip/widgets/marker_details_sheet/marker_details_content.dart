import 'package:flutter/material.dart';
import 'package:trip_planner/core/theme/colors.dart';
import 'package:trip_planner/core/theme/text_style.dart';
import 'package:trip_planner/features/trip/model/marker_point_model.dart';
import 'package:trip_planner/features/trip/services/google_places/google_places_models.dart';
import 'package:trip_planner/features/trip/widgets/nearby_places/google_nearby_places_section.dart';
import 'package:trip_planner/features/trip/widgets/marker_details_sheet/marker_description_section.dart';

class MarkerDetailsContent extends StatelessWidget {
  const MarkerDetailsContent({
    super.key,
    required this.marker,
    required this.onDescriptionChanged,
    required this.onNameChanged,
    required this.onPlaceSelected,
    required this.onDelete,
  });

  final MarkerPoint marker;
  final Function(String) onDescriptionChanged;
  final Function(String) onNameChanged;
  final Function(GooglePlace) onPlaceSelected;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(context),
          _buildDescription(),
          _buildNearbyPlaces(),
          _buildDeleteButton(),
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            marker.name ?? 'Bez nazwy',
            style: AppTextStyles.heading1,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.edit, size: 24),
          onPressed: () => _showEditNameDialog(context),
        ),
      ],
    );
  }

  Future<void> _showEditNameDialog(BuildContext context) async {
    final controller = TextEditingController(text: marker.name ?? '');

    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Zmień nazwę punktu',
          style: AppTextStyles.heading3,
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Wpisz nową nazwę...',
            border: OutlineInputBorder(),
          ),
          maxLength: 50,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Anuluj',
              style: AppTextStyles.bodySmallRed,
            ),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                Navigator.pop(context, name);
              }
            },
            child: Text(
              'Zapisz',
              style: AppTextStyles.bodySmallGreen,
            ),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty) {
      onNameChanged(newName);
    }
  }

  Widget _buildDescription() {
    return MarkerDescriptionSection(
      initialDescription: marker.description,
      onDescriptionChanged: onDescriptionChanged,
    );
  }

  Widget _buildNearbyPlaces() {
    return GoogleNearbyPlacesSection(
      markerPosition: marker.position,
      onPlaceSelected: onPlaceSelected,
    );
  }

  Widget _buildDeleteButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Center(
        child: IconButton(
          icon: const Icon(
            Icons.delete,
            color: AppColors.red,
            size: 32,
          ),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
