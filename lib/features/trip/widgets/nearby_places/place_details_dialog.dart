import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:trip_planner/features/trip/services/nominatim/nominatim.dart';

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
            _buildHeader(),
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
                  _buildCategoryChip(context),
                  const SizedBox(height: 16),
                  if (place.address != null) ...[
                    _buildInfoRow(
                      context,
                      icon: Icons.location_on_outlined,
                      label: 'Adres',
                      value: place.address!,
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (place.details != null) ...[
                    if (place.details!.description != null) ...[
                      _buildInfoRow(
                        context,
                        icon: Icons.info_outlined,
                        label: 'Opis',
                        value: place.details!.description!,
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (place.details!.openingHours != null) ...[
                      _buildInfoRow(
                        context,
                        icon: Icons.access_time,
                        label: 'Godziny otwarcia',
                        value: place.details!.openingHours!,
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (place.details!.phone != null) ...[
                      _buildClickableInfoRow(
                        context,
                        icon: Icons.phone_outlined,
                        label: 'Telefon',
                        value: place.details!.phone!,
                        onTap: () => _launchPhone(place.details!.phone!),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (place.details!.website != null) ...[
                      _buildClickableInfoRow(
                        context,
                        icon: Icons.language,
                        label: 'Strona www',
                        value: place.details!.website!,
                        onTap: () => _launchWebsite(place.details!.website!),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (place.details!.wikipedia != null) ...[
                      _buildClickableInfoRow(
                        context,
                        icon: Icons.menu_book,
                        label: 'Wikipedia',
                        value: 'Czytaj więcej',
                        onTap: () =>
                            _launchWikipedia(place.details!.wikipedia!),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Zamknij'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        onPressed: () => Navigator.of(context).pop(true),
                        icon: const Icon(Icons.add_location),
                        label: const Text('Dodaj do trasy'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    if (place.hasPhoto) {
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: Image.network(
          place.photoReference!,
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildEmojiHeader();
          },
        ),
      );
    } else {
      return _buildEmojiHeader();
    }
  }

  Widget _buildEmojiHeader() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade400,
            Colors.purple.shade400,
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Center(
        child: Text(
          place.categoryEmoji,
          style: const TextStyle(fontSize: 64),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            place.categoryEmoji,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 6),
          Text(
            place.category.displayName,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClickableInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          decoration: TextDecoration.underline,
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.open_in_new,
              size: 16,
              color: Colors.grey.shade600,
            ),
          ],
        ),
      ),
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
