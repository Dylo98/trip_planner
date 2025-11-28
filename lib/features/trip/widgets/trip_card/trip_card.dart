import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:trip_planner/core/theme/colors.dart';
import 'package:trip_planner/core/theme/text_style.dart';
import 'package:trip_planner/core/utils/action_lock.dart';
import 'package:trip_planner/features/trip/model/trip_model.dart';
import 'package:trip_planner/features/trip/screens/trip_details/trip_details_screen.dart';
import 'package:trip_planner/features/trip/utils/trip_sorting_helper.dart';
import 'package:trip_planner/features/trip/services/trip_service.dart';
import 'package:trip_planner/features/trip/controllers/trip_deletion_controller.dart';
import 'package:trip_planner/features/trip/widgets/trip_card/trip_card_overlay.dart';

class TripCard extends ConsumerWidget {
  const TripCard({
    super.key,
    required this.trip,
    required this.openTripLock,
  });

  final Trip trip;
  final ActionLock openTripLock;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalBudget = TripSortingHelper.calculateTotalBudget(trip);
    final formattedStartDate = _formatStartDate(trip.startDate);

    return Dismissible(
      key: Key('trip_${trip.id}'),
      direction: DismissDirection.endToStart,
      background: _buildDismissBackground(),
      confirmDismiss: (direction) => _handleDismissConfirmation(context, ref),
      onDismissed: (direction) => _handleDismissed(context, ref),
      child: _buildCard(context, formattedStartDate, totalBudget),
    );
  }

  Widget _buildCard(
    BuildContext context,
    String formattedStartDate,
    double totalBudget,
  ) {
    return OpenContainer(
      key: Key('openContainer_${trip.id}'),
      transitionType: ContainerTransitionType.fadeThrough,
      closedBuilder: (context, action) {
        return GestureDetector(
          onTap: () => _handleTap(action),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8.0,
              vertical: 4.0,
            ),
            child: Stack(
              children: [
                _buildImageCard(),
                TripCardOverlay(
                  trip: trip,
                  formattedStartDate: formattedStartDate,
                  totalBudget: totalBudget,
                ),
              ],
            ),
          ),
        );
      },
      openBuilder: (context, action) {
        return MainTripDetailsScreen(
          key: const Key('tripDetailsScreen'),
          trip: trip,
        );
      },
    );
  }

  Widget _buildImageCard() {
    return Card(
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      child: SizedBox(
        height: 250,
        width: double.infinity,
        child: _TripCardImage(urlImage: trip.tripPhotoUrl ?? ''),
      ),
    );
  }

  Widget _buildDismissBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: AppColors.red,
        borderRadius: BorderRadius.circular(30),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.delete, color: AppColors.white, size: 32),
          SizedBox(height: 4),
          Text(
            'Usuń',
            style: AppTextStyles.bodySmallWhite,
          ),
        ],
      ),
    );
  }

  Future<void> _handleTap(VoidCallback action) async {
    await openTripLock.run(() async {
      action();
      await Future<void>.delayed(Duration.zero);
    });
  }

  Future<bool?> _handleDismissConfirmation(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final controller = TripDeletionController(
      context: context,
      tripService: ref.read(tripServiceProvider),
    );

    return await controller.showConfirmationDialog(trip.name);
  }

  Future<void> _handleDismissed(BuildContext context, WidgetRef ref) async {
    final controller = TripDeletionController(
      context: context,
      tripService: ref.read(tripServiceProvider),
    );

    try {
      await ref.read(tripServiceProvider).deleteTrip(trip.id);
      controller.showSuccessMessage(trip.name);
    } catch (e) {
      controller.showErrorMessage(e);
    }
  }

  String _formatStartDate(DateTime? startDate) {
    if (startDate == null) return 'Brak daty';
    return DateFormat('dd-MM-yyyy').format(startDate);
  }
}

class _TripCardImage extends StatelessWidget {
  const _TripCardImage({required this.urlImage});

  final String urlImage;

  bool get _isValidUrl =>
      urlImage.isNotEmpty && Uri.tryParse(urlImage)?.hasAbsolutePath == true;

  @override
  Widget build(BuildContext context) {
    if (!_isValidUrl) {
      return _placeholder();
    }

    return CachedNetworkImage(
      imageUrl: urlImage,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      memCacheWidth: 1200,
      memCacheHeight: 1200,
      maxWidthDiskCache: 1600,
      maxHeightDiskCache: 1600,
      fadeInDuration: const Duration(milliseconds: 200),
      fadeOutDuration: const Duration(milliseconds: 150),
      placeholder: (context, _) => _loading(),
      errorWidget: (context, _, __) => _placeholder(),
    );
  }

  Widget _loading() {
    return Container(
      color: AppColors.grey,
      alignment: Alignment.center,
      child: const SizedBox(
        width: 28,
        height: 28,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppColors.limeSlice,
      alignment: Alignment.center,
    );
  }
}
