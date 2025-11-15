import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:trip_planner/features/trip/services/google_places_service.dart';

enum PlaceCategory {
  all('Wszystko', Icons.explore, []),
  restaurants('Restauracje', Icons.restaurant, ['restaurant', 'cafe', 'bar']),
  attractions('Atrakcje', Icons.attractions, [
    'tourist_attraction',
    'museum',
    'art_gallery',
    'zoo',
    'aquarium',
    'amusement_park'
  ]),
  culture('Kultura', Icons.theater_comedy,
      ['museum', 'art_gallery', 'library', 'theater', 'concert_hall']),
  nature('Natura', Icons.park, ['park', 'natural_feature', 'campground']),
  shopping(
      'Zakupy', Icons.shopping_bag, ['shopping_mall', 'store', 'supermarket']),
  entertainment('Rozrywka', Icons.local_activity,
      ['movie_theater', 'night_club', 'casino', 'bowling_alley']);

  final String label;
  final IconData icon;
  final List<String> types;

  const PlaceCategory(this.label, this.icon, this.types);
}

class GoogleNearbyPlacesSection extends StatefulWidget {
  const GoogleNearbyPlacesSection({
    super.key,
    required this.markerPosition,
    required this.onPlaceSelected,
  });

  final LatLng markerPosition;
  final Function(GooglePlace) onPlaceSelected;

  @override
  State<GoogleNearbyPlacesSection> createState() =>
      _GoogleNearbyPlacesSectionState();
}

class _GoogleNearbyPlacesSectionState extends State<GoogleNearbyPlacesSection> {
  List<GooglePlace> _places = [];
  bool _isLoading = true;
  String? _errorMessage;
  CostStatistics? _stats;
  PlaceCategory _selectedCategory = PlaceCategory.all;

  @override
  void initState() {
    super.initState();
    _loadPlaces();
  }

  Future<void> _loadPlaces() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      var places = await GooglePlacesService.getNearbyPlaces(
        location: widget.markerPosition,
        radiusMeters: 1500,
        types: _selectedCategory != PlaceCategory.all
            ? _selectedCategory.types
            : null,
      );

      if (places.isEmpty) {
        places = await GooglePlacesService.getNearbyPlaces(
          location: widget.markerPosition,
          radiusMeters: 5000,
          types: _selectedCategory != PlaceCategory.all
              ? _selectedCategory.types
              : null,
        );
      }

      final stats = GooglePlacesService.getCostStatistics();

      if (mounted) {
        setState(() {
          _places = places;
          _isLoading = false;
          _stats = stats;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Błąd: $e';
        });
      }
    }
  }

  void _onCategoryChanged(PlaceCategory category) {
    if (_selectedCategory != category) {
      setState(() {
        _selectedCategory = category;
      });
      _loadPlaces();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 32),
        _buildHeader(),
        const SizedBox(height: 12),
        _buildCategoryFilter(),
        const SizedBox(height: 8),
        if (_stats != null) _buildCostIndicator(),
        const SizedBox(height: 12),
        _buildContent(),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade400, Colors.purple.shade400],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.stars,
              size: 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ciekawe miejsca w pobliżu',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (!_isLoading && _places.isNotEmpty)
            Chip(
              label: Text(
                '${_places.length}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              backgroundColor: Colors.blue.shade100,
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: PlaceCategory.values.length,
        itemBuilder: (context, index) {
          final category = PlaceCategory.values[index];
          final isSelected = _selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    category.icon,
                    size: 16,
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                  ),
                  const SizedBox(width: 6),
                  Text(category.label),
                ],
              ),
              selected: isSelected,
              onSelected: (_) => _onCategoryChanged(category),
              selectedColor: Colors.blue.shade600,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade800,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 13,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCostIndicator() {
    if (_stats == null) return const SizedBox.shrink();

    final isWarning = _stats!.isNearDailyLimit;
    final color = isWarning ? Colors.orange : Colors.green;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isWarning ? Icons.warning_amber : Icons.check_circle,
              size: 14,
              color: color,
            ),
            const SizedBox(width: 6),
            Text(
              '${_stats!.dailyRequests}/${_stats!.maxDailyRequests} zapytań | ${_stats!.costFormatted}',
              style: TextStyle(
                fontSize: 11,
                color: color.shade800,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_places.isEmpty) {
      return _buildEmptyState();
    }

    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: _places.length,
        itemBuilder: (context, index) {
          return _GooglePlaceCard(
            place: _places[index],
            onTap: () => _handlePlaceTap(_places[index]),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 220,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 12),
          Text(
            'Szukam ciekawych miejsc...',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 220,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            'Brak miejsc w kategorii "${_selectedCategory.label}"',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => _onCategoryChanged(PlaceCategory.all),
            icon: const Icon(Icons.explore, size: 16),
            label: const Text('Pokaż wszystkie'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      height: 220,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red.shade300,
          ),
          const SizedBox(height: 12),
          Text(
            _errorMessage!,
            style: TextStyle(
              color: Colors.red.shade700,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: _loadPlaces,
            icon: const Icon(Icons.refresh),
            label: const Text('Spróbuj ponownie'),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePlaceTap(GooglePlace place) async {
    final shouldAdd = await showDialog<bool>(
      context: context,
      builder: (context) => _EnhancedPlaceDetailsDialog(place: place),
    );

    if (shouldAdd == true) {
      widget.onPlaceSelected(place);
    }
  }
}

class _GooglePlaceCard extends StatelessWidget {
  const _GooglePlaceCard({
    required this.place,
    required this.onTap,
  });

  final GooglePlace place;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        place.categoryEmoji,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          place.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (place.rating != null) ...[
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 14,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          place.rating!.toStringAsFixed(1),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        if (place.userRatingsTotal != null) ...[
                          Text(
                            ' (${place.userRatingsTotal})',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    place.categoryName,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    final photoUrl = place.photoReference != null
        ? GooglePlacesService.getPhotoUrl(place.photoReference!, maxWidth: 400)
        : null;

    if (photoUrl != null) {
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: CachedNetworkImage(
          imageUrl: photoUrl,
          height: 110,
          width: double.infinity,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            height: 110,
            color: Colors.grey.shade200,
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          errorWidget: (context, url, error) => _buildEmojiPlaceholder(),
        ),
      );
    }

    return _buildEmojiPlaceholder();
  }

  Widget _buildEmojiPlaceholder() {
    return Container(
      height: 110,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade300,
            Colors.purple.shade300,
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Center(
        child: Text(
          place.categoryEmoji,
          style: const TextStyle(fontSize: 52),
        ),
      ),
    );
  }
}

class _EnhancedPlaceDetailsDialog extends StatefulWidget {
  const _EnhancedPlaceDetailsDialog({required this.place});

  final GooglePlace place;

  @override
  State<_EnhancedPlaceDetailsDialog> createState() =>
      _EnhancedPlaceDetailsDialogState();
}

class _EnhancedPlaceDetailsDialogState
    extends State<_EnhancedPlaceDetailsDialog> {
  GooglePlaceDetails? _details;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    final details =
        await GooglePlacesService.getPlaceDetails(widget.place.placeId);
    if (mounted) {
      setState(() {
        _details = details;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final photoUrl = widget.place.photoReference != null
        ? GooglePlacesService.getPhotoUrl(
            widget.place.photoReference!,
            maxWidth: 600,
          )
        : null;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: photoUrl != null
          ? CachedNetworkImage(
              imageUrl: photoUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 200,
                color: Colors.grey.shade300,
              ),
              errorWidget: (context, url, error) => _buildEmojiHeader(),
            )
          : _buildEmojiHeader(),
    );
  }

  Widget _buildEmojiHeader() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.purple.shade400],
        ),
      ),
      child: Center(
        child: Text(
          widget.place.categoryEmoji,
          style: const TextStyle(fontSize: 72),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.place.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildRating(),
              const Spacer(),
              if (_details?.openingHoursStatus != null) _buildOpenNowChip(),
            ],
          ),
          const SizedBox(height: 16),
          if (_details?.editorialSummary != null) ...[
            _buildSectionTitle('Opis'),
            Text(
              _details!.editorialSummary!,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 16),
          ],
          if (_details?.formattedAddress != null) ...[
            _buildInfoRow(
              icon: Icons.location_on,
              label: 'Adres',
              value: _details!.formattedAddress!,
              onTap: _details!.url != null
                  ? () => _launchUrl(_details!.url!)
                  : null,
            ),
            const SizedBox(height: 12),
          ],
          if (_details?.phoneNumber != null) ...[
            _buildInfoRow(
              icon: Icons.phone,
              label: 'Telefon',
              value: _details!.phoneNumber!,
              onTap: () => _launchUrl('tel:${_details!.phoneNumber}'),
            ),
            const SizedBox(height: 12),
          ],
          if (_details?.website != null) ...[
            _buildInfoRow(
              icon: Icons.language,
              label: 'Strona internetowa',
              value: _details!.website!,
              onTap: () => _launchUrl(_details!.website!),
            ),
            const SizedBox(height: 12),
          ],
          if (_details?.priceLevel != null) ...[
            _buildInfoRow(
              icon: Icons.attach_money,
              label: 'Poziom cen',
              value: _details!.priceLevelString,
            ),
            const SizedBox(height: 12),
          ],
          if (_details?.openingHours != null &&
              _details!.openingHours!.isNotEmpty) ...[
            const Divider(height: 32),
            _buildSectionTitle('Godziny otwarcia'),
            const SizedBox(height: 8),
            ..._details!.openingHours!.map((hours) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  hours,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
          ],
          if (_details?.reviews != null && _details!.reviews!.isNotEmpty) ...[
            const Divider(height: 32),
            _buildSectionTitle('Recenzje (${_details!.reviews!.length})'),
            const SizedBox(height: 12),
            ..._details!.reviews!.map((review) => _buildReviewCard(review)),
          ],
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Zamknij'),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: () => Navigator.pop(context, true),
                icon: const Icon(Icons.add_location),
                label: const Text('Dodaj do trasy'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildRating() {
    if (widget.place.rating == null) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (index) {
          return Icon(
            index < (widget.place.rating ?? 0).floor()
                ? Icons.star
                : Icons.star_border,
            color: Colors.amber,
            size: 20,
          );
        }),
        const SizedBox(width: 8),
        Text(
          '${widget.place.rating!.toStringAsFixed(1)} (${widget.place.userRatingsTotal ?? 0})',
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildOpenNowChip() {
    final isOpen = _details!.openingHoursStatus!.openNow;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isOpen ? Colors.green.shade100 : Colors.red.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isOpen ? Colors.green.shade300 : Colors.red.shade300,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOpen ? Icons.check_circle : Icons.cancel,
            size: 14,
            color: isOpen ? Colors.green.shade700 : Colors.red.shade700,
          ),
          const SizedBox(width: 6),
          Text(
            isOpen ? 'Otwarte' : 'Zamknięte',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isOpen ? Colors.green.shade700 : Colors.red.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    final isClickable = onTap != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: Colors.blue),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      color: isClickable ? Colors.blue : Colors.black87,
                      decoration: isClickable
                          ? TextDecoration.underline
                          : TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
            if (isClickable)
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

  Widget _buildReviewCard(PlaceReview review) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    review.authorName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < review.rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 14,
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              review.relativeTimeDescription,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              review.text,
              style: const TextStyle(fontSize: 13),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _launchUrl(String url) async {
    try {
      if (!url.startsWith('http://') &&
          !url.startsWith('https://') &&
          !url.startsWith('tel:')) {
        url = 'https://$url';
      }
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Nie można otworzyć: $url')),
        );
      }
    }
  }
}
