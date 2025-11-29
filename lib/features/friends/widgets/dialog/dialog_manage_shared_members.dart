import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/core/theme/button_style.dart';
import 'package:trip_planner/core/theme/colors.dart';
import 'package:trip_planner/core/theme/text_style.dart';
import 'package:trip_planner/core/utils/action_lock.dart';
import 'package:trip_planner/core/widgets/app_notifications.dart';
import 'package:trip_planner/core/widgets/dialog/dialog_confirmation.dart';
import 'package:trip_planner/features/friends/controller/friends_provider.dart';
import 'package:trip_planner/features/friends/model/shared_trip_member_model.dart';
import 'package:trip_planner/features/friends/widgets/dialog/dialog_components/dialog_shared_member_item.dart';

class ManageSharedMembersDialog extends ConsumerStatefulWidget {
  const ManageSharedMembersDialog({
    super.key,
    required this.tripId,
    required this.tripName,
  });

  final String tripId;
  final String tripName;

  @override
  ConsumerState<ManageSharedMembersDialog> createState() =>
      _ManageSharedMembersDialogState();
}

class _ManageSharedMembersDialogState
    extends ConsumerState<ManageSharedMembersDialog> {
  final _actionLock = ActionLock();

  @override
  Widget build(BuildContext context) {
    final sharedMembersAsync = ref.watch(sharedMembersProvider(widget.tripId));

    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.people, color: AppColors.limeSliceDark),
              SizedBox(width: 8),
              Text('Współwłaściciele', style: AppTextStyles.heading3),
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
        child: sharedMembersAsync.when(
          data: (members) {
            if (members.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 64,
                      color: AppColors.limeSliceDark,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Nie udostępniłeś tej podróży\nżadnemu znajomemu',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyTextSecondary,
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              itemCount: members.length,
              itemBuilder: (context, index) {
                final member = members[index];
                return DialogSharedMemberItem(
                  member: member,
                  onChangeRole: () => _showChangeRoleDialog(member),
                  onRemove: () => _confirmRemoveMember(member),
                );
              },
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (_, __) => const Padding(
            padding: EdgeInsets.all(32),
            child: Text(
              'Błąd podczas ładowania członków',
              style: AppTextStyles.bodySmallRed,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      actions: [
        GradientButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.close,
            color: AppColors.darkGrey,
          ),
          child: const Text(
            'Zamknij',
            style: AppTextStyles.buttonText,
          ),
        ),
      ],
    );
  }

  Future<void> _showChangeRoleDialog(SharedTripMember member) async {
    final newRole = await showDialog<TripRole>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Zmień uprawnienia: ${member.displayName}',
          style: AppTextStyles.heading3,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: AppColors.limeSliceDark),
              title: const Text('Edytor', style: AppTextStyles.bodyText),
              subtitle: const Text(
                'Może dodawać i edytować punkty',
                style: AppTextStyles.bodyTextSecondary,
              ),
              trailing: member.role == TripRole.editor
                  ? const Icon(Icons.check, color: AppColors.limeSliceDark)
                  : null,
              onTap: () => Navigator.pop(context, TripRole.editor),
            ),
            ListTile(
              leading: const Icon(
                Icons.visibility,
                color: AppColors.limeSliceDark,
              ),
              title: const Text('Widz', style: AppTextStyles.bodyText),
              subtitle: const Text(
                'Tylko podgląd podróży',
                style: AppTextStyles.bodyTextSecondary,
              ),
              trailing: member.role == TripRole.viewer
                  ? const Icon(Icons.check, color: AppColors.limeSliceDark)
                  : null,
              onTap: () => Navigator.pop(context, TripRole.viewer),
            ),
          ],
        ),
      ),
    );

    if (newRole == null || newRole == member.role) return;

    await _actionLock.run(() async {
      try {
        await ref.read(sharedTripServiceProvider).updateMemberRole(
              tripId: widget.tripId,
              memberUid: member.uid,
              newRole: newRole,
            );

        if (mounted) {
          AppNotifications.showSuccess(
            context: context,
            message: 'Zmieniono uprawnienia użytkownika ${member.displayName}',
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

  Future<void> _confirmRemoveMember(SharedTripMember member) async {
    final confirmed = await DialogConfirmation.show(
      context: context,
      title: 'Usuń dostęp',
      content:
          'Czy na pewno chcesz usunąć dostęp dla ${member.displayName}?\n\n'
          'Ta osoba nie będzie już mogła przeglądać ani edytować tej podróży.',
      confirmText: 'Usuń',
      cancelText: 'Anuluj',
      isDestructive: true,
      icon: Icons.person_remove_alt_1,
    );

    if (!confirmed) return;

    await _actionLock.run(() async {
      try {
        await ref.read(sharedTripServiceProvider).removeSharedAccess(
              tripId: widget.tripId,
              memberUid: member.uid,
            );

        if (mounted) {
          AppNotifications.showSuccess(
            context: context,
            message: 'Usunięto dostęp dla: ${member.displayName}',
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
