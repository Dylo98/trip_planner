import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:trip_planner/features/trip/services/google_places/google_places_service.dart';
import 'package:trip_planner/features/trip/services/google_places/google_places_models.dart';

class PlaceDetailsBottomSheet extends StatefulWidget {
  const PlaceDetailsBottomSheet({
    super.key,
    required this.place,
    required this.onAddToTrip,
  });

  final GooglePlace place;
  final VoidCallback onAddToTrip;

  @override
  State<PlaceDetailsBottomSheet> createState() =>
      _PlaceDetailsBottomSheetState();
}

class _PlaceDetailsBottomSheetState extends State<PlaceDetailsBottomSheet> {
  GooglePlaceDetails? _details;
  bool _isLoading = true;
  final _googlePlacesService = GooglePlacesService();

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    try {
      final details =
          await _googlePlacesService.getPlaceDetails(widget.place.placeId);

      if (mounted) {
        setState(() {
          _details = details;
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error loading place details: $e');
      debugPrint('Stack trace: $stackTrace');

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
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
        ? _googlePlacesService.getPhotoUrl(
            widget.place.photoReference!,
            maxWidth: 600,
          )
        : null;

    if (photoUrl == null) {
      return _buildEmojiHeader();
    }

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: CachedNetworkImage(
        imageUrl: photoUrl,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          height: 200,
          color: Colors.grey.shade300,
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: (context, url, error) => _buildEmojiHeader(),
      ),
    );
  }

  Widget _buildEmojiHeader() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.purple.shade400],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
          _buildTitle(),
          const SizedBox(height: 8),
          _buildRatingRow(),
          const SizedBox(height: 16),
          if (_details == null) ...[
            _buildNoDetailsWarning(),
            const SizedBox(height: 16),
          ],
          if (_details?.editorialSummary != null) ...[
            _buildDescription(),
            const SizedBox(height: 16),
          ],
          if (_details?.formattedAddress != null) ...[
            _buildAddressRow(),
            const SizedBox(height: 12),
          ],
          if (_details?.phoneNumber != null) ...[
            _buildPhoneRow(),
            const SizedBox(height: 12),
          ],
          if (_details?.website != null) ...[
            _buildWebsiteRow(),
            const SizedBox(height: 12),
          ],
          if (_details?.openingHours != null) ...[
            _buildOpeningHours(),
            const SizedBox(height: 16),
          ],
          if (_details?.reviews != null && _details!.reviews!.isNotEmpty) ...[
            _buildReviews(),
            const SizedBox(height: 16),
          ],
          if (_details?.photoReferences != null &&
              _details!.photoReferences!.length > 1) ...[
            _buildPhotoGallery(),
            const SizedBox(height: 16),
          ],
          if (_details?.formattedAddress == null &&
              _details?.phoneNumber == null &&
              _details?.website == null) ...[
            _buildBasicInfo(),
            const SizedBox(height: 16),
          ],
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildNoDetailsWarning() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.orange.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Szczegółowe informacje niedostępne dla tego miejsca',
              style: TextStyle(
                fontSize: 13,
                color: Colors.orange.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Podstawowe informacje'),
        if (widget.place.vicinity != null) ...[
          _buildInfoRow(
            icon: Icons.location_on,
            label: 'Lokalizacja',
            value: widget.place.vicinity!,
            onTap: null,
          ),
          const SizedBox(height: 8),
        ],
        _buildInfoRow(
          icon: Icons.category,
          label: 'Kategoria',
          value: widget.place.categoryName,
          onTap: null,
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return Text(
      widget.place.name,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildRatingRow() {
    return Row(
      children: [
        if (widget.place.rating != null) ...[
          Icon(
            Icons.star,
            color: Colors.amber.shade700,
            size: 20,
          ),
          const SizedBox(width: 4),
          Text(
            widget.place.rating!.toStringAsFixed(1),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          if (widget.place.userRatingsTotal != null) ...[
            const SizedBox(width: 4),
            Text(
              '(${widget.place.userRatingsTotal} opinii)',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ],
        ],
        const Spacer(),
        if (_details?.openingHoursStatus != null) _buildOpenNowChip(),
      ],
    );
  }

  Widget _buildOpenNowChip() {
    final isOpen = _details!.openingHoursStatus!.openNow;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isOpen ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isOpen ? Colors.green : Colors.red,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOpen ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: isOpen ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 4),
          Text(
            isOpen ? 'Otwarte' : 'Zamknięte',
            style: TextStyle(
              color: isOpen ? Colors.green.shade700 : Colors.red.shade700,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Opis'),
        Text(
          _details!.editorialSummary!,
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildAddressRow() {
    return _buildInfoRow(
      icon: Icons.location_on,
      label: 'Adres',
      value: _details!.formattedAddress!,
      onTap: _details!.url != null ? () => _launchUrl(_details!.url!) : null,
    );
  }

  Widget _buildPhoneRow() {
    return _buildInfoRow(
      icon: Icons.phone,
      label: 'Telefon',
      value: _details!.phoneNumber!,
      onTap: () => _launchUrl('tel:${_details!.phoneNumber}'),
    );
  }

  Widget _buildWebsiteRow() {
    return _buildInfoRow(
      icon: Icons.language,
      label: 'Strona internetowa',
      value: _details!.website!,
      onTap: () => _launchUrl(_details!.website!),
    );
  }

  Widget _buildOpeningHours() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Godziny otwarcia'),
        ..._details!.openingHours!.map((hours) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                hours,
                style: const TextStyle(fontSize: 14),
              ),
            )),
      ],
    );
  }

  Widget _buildReviews() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Opinie'),
        ..._details!.reviews!.map((review) => _buildReviewCard(review)),
      ],
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
                Text(
                  review.authorName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      size: 16,
                      color: Colors.amber.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      review.rating.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              review.relativeTimeDescription,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              review.text,
              style: const TextStyle(fontSize: 14, height: 1.4),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoGallery() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Zdjęcia'),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _details!.photoReferences!.length,
            itemBuilder: (context, index) {
              final photoRef = _details!.photoReferences![index];
              final photoUrl =
                  _googlePlacesService.getPhotoUrl(photoRef, maxWidth: 200);

              if (photoUrl == null) {
                return const SizedBox.shrink();
              }

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: photoUrl,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.broken_image),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Zamknij'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              widget.onAddToTrip();
            },
            icon: const Icon(Icons.add_location),
            label: const Text('Dodaj do trasy'),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: Colors.blue.shade700),
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
                      color: onTap != null ? Colors.blue : Colors.black87,
                      decoration:
                          onTap != null ? TextDecoration.underline : null,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
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

  Future<void> _launchUrl(String urlString) async {
    try {
      final url = Uri.parse(urlString);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Nie można otworzyć linku: $e')),
        );
      }
    }
  }
}
