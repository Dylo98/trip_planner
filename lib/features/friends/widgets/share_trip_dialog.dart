import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/core/widgets/app_notifications.dart';
import 'package:trip_planner/features/friends/controller/friends_provider.dart';
import 'package:trip_planner/features/friends/service/shared_trip_service.dart';
import 'package:trip_planner/core/utils/action_lock.dart';

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
    final friendsAsync = ref.watch(friendsProvider);
    final sharedMembersAsync = ref.watch(sharedMembersProvider(widget.tripId));

    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.share, color: Colors.blue),
              SizedBox(width: 8),
              Text('Udostępnij podróż'),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.tripName,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: Colors.grey,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Wybierz znajomego:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            friendsAsync.when(
              data: (friends) {
                debugPrint('friends: ${friends.length}');
                final sharedMembers = sharedMembersAsync.value ?? [];
                final sharedUids = sharedMembers.map((m) => m.uid).toSet();
                final availableFriends =
                    friends.where((f) => !sharedUids.contains(f.uid)).toList();
                debugPrint('availableFriends: ${availableFriends.length}');

                if (friends.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Nie masz jeszcze znajomych.\nDodaj znajomych, aby móc udostępniać podróże.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                if (availableFriends.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Wszyscy Twoi znajomi mają już dostęp do tej podróży.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return DropdownButtonFormField<String>(
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Znajomy',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  value: _selectedFriendUid,
                  items: availableFriends.map((friend) {
                    return DropdownMenuItem(
                      value: friend.uid,
                      child: Text(friend.displayName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedFriendUid = value);
                  },
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => const Text(
                'Błąd podczas ładowania znajomych',
                style: TextStyle(color: Colors.red),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Uprawnienia:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<TripRole>(
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Uprawnienia',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              value: _selectedRole,
              items: const [
                DropdownMenuItem(
                  value: TripRole.editor,
                  child: Text('Edytor – może dodawać i edytować punkty'),
                ),
                DropdownMenuItem(
                  value: TripRole.viewer,
                  child: Text('Widz – tylko podgląd podróży'),
                ),
              ],
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
          child: const Text('Anuluj'),
        ),
        ElevatedButton.icon(
          onPressed: _selectedFriendUid == null ? null : _shareTrip,
          icon: const Icon(Icons.share),
          label: const Text('Udostępnij'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
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
