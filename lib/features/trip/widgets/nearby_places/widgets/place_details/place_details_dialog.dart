import 'package:flutter/material.dart';
import 'package:trip_planner/core/widgets/dialog/dialog_actions_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:trip_planner/features/trip/services/nominatim/nominatim.dart';
import 'package:trip_planner/features/trip/widgets/nearby_places/widgets/place_details/components/place_details_header.dart';
import 'package:trip_planner/features/trip/widgets/nearby_places/widgets/place_details/components/place_details_category_chip.dart';
import 'package:trip_planner/features/trip/widgets/nearby_places/widgets/place_details/components/place_details_info_row.dart';

class PlaceDetailsDialog extends StatelessWidget {
  final PlaceSuggestion place;

  const PlaceDetailsDialog({
    super.key,
    required this.place,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PlaceDetailsHeader(
              photoUrl: place.hasPhoto ? place.photoReference : null,
              categoryEmoji: place.categoryEmoji,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  PlaceDetailsCategoryChip(
                    emoji: place.categoryEmoji,
                    label: place.category.displayName,
                  ),
                  const SizedBox(height: 16),
                  _buildDetailsSection(context),
                  const SizedBox(height: 8),
                  DialogActionsBar(
                    onCancel: () => Navigator.of(context).pop(false),
                    onConfirm: () => Navigator.of(context).pop(true),
                    cancelLabel: 'Zamknij',
                    addLabel: 'Dodaj do trasy',
                    saveLabel: 'Dodaj do trasy',
                    isEditing: false,
                    isConfirmEnabled: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsSection(BuildContext context) {
    return Column(
      children: [
        if (place.address != null) ...[
          PlaceDetailsInfoRow(
            icon: Icons.location_on_outlined,
            label: 'Adres',
            value: place.address!,
          ),
          const SizedBox(height: 12),
        ],
        if (place.details != null) ...[
          if (place.details!.description != null) ...[
            PlaceDetailsInfoRow(
              icon: Icons.info_outlined,
              label: 'Opis',
              value: place.details!.description!,
            ),
            const SizedBox(height: 12),
          ],
          if (place.details!.openingHours != null) ...[
            PlaceDetailsInfoRow(
              icon: Icons.access_time,
              label: 'Godziny otwarcia',
              value: place.details!.openingHours!,
            ),
            const SizedBox(height: 12),
          ],
          if (place.details!.phone != null) ...[
            PlaceDetailsInfoRow(
              icon: Icons.phone_outlined,
              label: 'Telefon',
              value: place.details!.phone!,
              onTap: () => _launchPhone(place.details!.phone!),
            ),
            const SizedBox(height: 12),
          ],
          if (place.details!.website != null) ...[
            PlaceDetailsInfoRow(
              icon: Icons.language,
              label: 'Strona www',
              value: place.details!.website!,
              onTap: () => _launchWebsite(place.details!.website!),
            ),
            const SizedBox(height: 12),
          ],
          if (place.details!.wikipedia != null) ...[
            PlaceDetailsInfoRow(
              icon: Icons.menu_book,
              label: 'Wikipedia',
              value: 'Czytaj wiÄ™cej',
              onTap: () => _launchWikipedia(place.details!.wikipedia!),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ],
    );
  }

  void _launchWebsite(String url) {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    final uri = Uri.parse(url);
    launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _launchPhone(String phone) {
    final uri = Uri.parse('tel:$phone');
    launchUrl(uri);
  }

  void _launchWikipedia(String wikipediaRef) {
    final parts = wikipediaRef.split(':');
    if (parts.length == 2) {
      final lang = parts[0];
      final title = parts[1];
      final url = 'https://$lang.wikipedia.org/wiki/$title';
      _launchWebsite(url);
    }
  }
}

Future<bool> showPlaceDetailsDialog(
  BuildContext context,
  PlaceSuggestion place,
) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => PlaceDetailsDialog(place: place),
  );
  return result ?? false;
}
