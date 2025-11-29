import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/core/theme/colors.dart';
import 'package:trip_planner/core/theme/text_style.dart';
import 'package:trip_planner/core/utils/action_lock.dart';
import 'package:trip_planner/core/widgets/app_notifications.dart';
import 'package:trip_planner/features/friends/controller/friends_provider.dart';
import 'package:trip_planner/features/friends/model/shared_trip_member_model.dart';
import 'package:trip_planner/features/friends/widgets/dialog/dialog_components/dialog_friend_selector.dart';
import 'package:trip_planner/features/friends/widgets/dialog/dialog_components/dialog_role_selector.dart';
import 'package:trip_planner/core/theme/button_style.dart';

class ShareTripDialog extends ConsumerStatefulWidget {
  const ShareTripDialog({
    super.key,
    required this.tripId,
    required this.tripName,
  });

  final String tripId;
  final String tripName;

  @override
  ConsumerState<ShareTripDialog> createState() => _ShareTripDialogState();
}

class _ShareTripDialogState extends ConsumerState<ShareTripDialog> {
  final _actionLock = ActionLock();
  String? _selectedFriendUid;
  TripRole _selectedRole = TripRole.editor;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.share, color: AppColors.limeSliceDark),
              SizedBox(width: 8),
              Text('Udostępnij podróż', style: AppTextStyles.heading3),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.tripName,
            style: AppTextStyles.bodyTextSecondary,
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DialogFriendSelector(
              tripId: widget.tripId,
              selectedFriendUid: _selectedFriendUid,
              onChanged: (value) {
                setState(() => _selectedFriendUid = value);
              },
            ),
            const SizedBox(height: 20),
            DialogRoleSelector(
              selectedRole: _selectedRole,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedRole = value);
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Anuluj',
            style: AppTextStyles.bodySmallRed,
          ),
        ),
        GradientButton(
          onPressed: _selectedFriendUid == null ? null : _shareTrip,
          icon: const Icon(
            Icons.share,
            color: AppColors.darkGrey,
          ),
          child: const Text(
            'Udostępnij',
            style: AppTextStyles.buttonText,
          ),
        ),
      ],
    );
  }

  Future<void> _shareTrip() async {
    if (_selectedFriendUid == null) return;

    await _actionLock.run(() async {
      try {
        await ref.read(sharedTripServiceProvider).shareTrip(
              tripId: widget.tripId,
              friendUid: _selectedFriendUid!,
              role: _selectedRole,
            );

        if (mounted) {
          Navigator.pop(context);
          AppNotifications.showSuccess(
            context: context,
            message: 'Udostępniono podróż znajomemu',
          );
        }
      } catch (e) {
        if (mounted) {
          AppNotifications.showError(
            context: context,
            message: 'Błąd: $e',
          );
        }
      }
    });
  }
}
