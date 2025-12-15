import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:trip_planner/core/widgets/app_notifications.dart';
import 'package:trip_planner/features/trip/services/google_places/google_places_service.dart';
import 'package:trip_planner/features/trip/services/google_places/google_places_models.dart';
import 'package:trip_planner/features/trip/widgets/nearby_places/widgets/place_details/components/place_details_header.dart';
import 'package:trip_planner/features/trip/widgets/nearby_places/widgets/place_details/components/place_details_rating_section.dart';
import 'package:trip_planner/features/trip/widgets/nearby_places/widgets/place_details/components/place_details_description.dart';
import 'package:trip_planner/features/trip/widgets/nearby_places/widgets/place_details/components/place_details_opening_hours.dart';
import 'package:trip_planner/features/trip/widgets/nearby_places/widgets/place_details/components/place_details_reviews_section.dart';
import 'package:trip_planner/features/trip/widgets/nearby_places/widgets/place_details/components/place_details_photo_gallery.dart';
import 'package:trip_planner/features/trip/widgets/nearby_places/widgets/place_details/components/place_details_action_buttons.dart';
import 'package:trip_planner/features/trip/widgets/nearby_places/widgets/place_details/components/place_details_info_row.dart';
import 'package:trip_planner/features/trip/widgets/nearby_places/widgets/place_details/components/place_details_section_title.dart';

class PlaceDetailsBottomSheet extends StatefulWidget {
  const PlaceDetailsBottomSheet({
    super.key,
    required this.place,
    required this.onAddToTrip,
  });

  final GooglePlace place;
  final Future<void> Function() onAddToTrip;

  @override
  State<PlaceDetailsBottomSheet> createState() =>
      _PlaceDetailsBottomSheetState();
}

class _PlaceDetailsBottomSheetState extends State<PlaceDetailsBottomSheet> {
  GooglePlaceDetails? _details;
  bool _isLoading = true;
  bool _isAdding = false;
  String? _errorMessage;
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
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _handleAddToTrip() async {
    if (_isAdding) return;

    setState(() => _isAdding = true);

    try {
      await widget.onAddToTrip();

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isAdding = false);
        AppNotifications.showError(
          context: context,
          message: 'Nie udało się dodać miejsca do podróży',
        );
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
            PlaceDetailsHeader(
              photoReference: widget.place.photoReference,
              categoryEmoji: widget.place.categoryEmoji,
            ),
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

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PlaceDetailsRatingSection(
            name: widget.place.name,
            rating: widget.place.rating,
            userRatingsTotal: widget.place.userRatingsTotal,
            openingHoursStatus: _details?.openingHoursStatus,
          ),
          const SizedBox(height: 16),
          if (_errorMessage != null) ...[
            _buildErrorWarning(_errorMessage!),
            const SizedBox(height: 16),
          ],
          if (_details == null && _errorMessage == null) ...[
            _buildNoDetailsWarning(),
            const SizedBox(height: 16),
          ],
          if (_details?.editorialSummary != null) ...[
            PlaceDetailsDescription(
              description: _details!.editorialSummary!,
            ),
            const SizedBox(height: 16),
          ],
          if (_details?.formattedAddress != null) ...[
            PlaceDetailsInfoRow(
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
            PlaceDetailsInfoRow(
              icon: Icons.phone,
              label: 'Telefon',
              value: _details!.phoneNumber!,
              onTap: () => _launchUrl('tel:${_details!.phoneNumber}'),
            ),
            const SizedBox(height: 12),
          ],
          if (_details?.website != null) ...[
            PlaceDetailsInfoRow(
              icon: Icons.language,
              label: 'Strona internetowa',
              value: _details!.website!,
              onTap: () => _launchUrl(_details!.website!),
            ),
            const SizedBox(height: 12),
          ],
          if (_details?.openingHours != null) ...[
            PlaceDetailsOpeningHours(
              openingHours: _details!.openingHours!,
            ),
            const SizedBox(height: 16),
          ],
          if (_details?.reviews != null && _details!.reviews!.isNotEmpty) ...[
            PlaceDetailsReviewsSection(
              reviews: _details!.reviews!,
            ),
            const SizedBox(height: 16),
          ],
          if (_details?.photoReferences != null &&
              _details!.photoReferences!.length > 1) ...[
            PlaceDetailsPhotoGallery(
              photoReferences: _details!.photoReferences!,
            ),
            const SizedBox(height: 16),
          ],
          if (_details?.formattedAddress == null &&
              _details?.phoneNumber == null &&
              _details?.website == null) ...[
            _buildBasicInfo(),
            const SizedBox(height: 16),
          ],
          PlaceDetailsActionButtons(
            onClose: () => Navigator.pop(context),
            onAddToTrip: _handleAddToTrip,
            isLoading: _isAdding,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWarning(String error) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Błąd pobierania szczegółów',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  error,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red.shade800,
                  ),
                ),
              ],
            ),
          ),
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
        const PlaceDetailsSectionTitle(title: 'Podstawowe informacje'),
        if (widget.place.vicinity != null) ...[
          PlaceDetailsInfoRow(
            icon: Icons.location_on,
            label: 'Lokalizacja',
            value: widget.place.vicinity!,
            onTap: null,
          ),
          const SizedBox(height: 8),
        ],
        PlaceDetailsInfoRow(
          icon: Icons.category,
          label: 'Kategoria',
          value: widget.place.categoryName,
          onTap: null,
        ),
      ],
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
        AppNotifications.showError(
          context: context,
          message: 'Nie można otworzyć linku',
        );
      }
    }
  }
}
