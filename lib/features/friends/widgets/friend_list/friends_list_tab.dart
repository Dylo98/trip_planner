import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/core/widgets/app_notifications.dart';
import 'package:trip_planner/core/widgets/dialog/dialog_confirmation.dart';
import 'package:trip_planner/features/friends/controller/friends_provider.dart';
import 'package:trip_planner/features/friends/model/friend_model.dart';
import 'package:trip_planner/features/friends/widgets/friend_list/friend_list_item.dart';
import 'package:trip_planner/features/friends/widgets/friend_list/friends_empty_state.dart';

class FriendsListTab extends ConsumerWidget {
  const FriendsListTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendsAsync = ref.watch(friendsProvider);

    return friendsAsync.when(
      data: (friends) {
        if (friends.isEmpty) {
          return const FriendsEmptyState();
        }

        return ListView.builder(
          itemCount: friends.length,
          padding: const EdgeInsets.all(8),
          itemBuilder: (context, index) {
            final friend = friends[index];
            return FriendListItem(
              friend: friend,
              onRemove: () => _confirmRemoveFriend(context, ref, friend),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Błąd podczas ładowania znajomych'),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => ref.invalidate(friendsProvider),
              child: const Text('Spróbuj ponownie'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmRemoveFriend(
    BuildContext context,
    WidgetRef ref,
    Friend friend,
  ) async {
    final confirmed = await ConfirmationDialogs.removeFriend(
      context: context,
      friendName: friend.displayName,
    );

    if (!confirmed || !context.mounted) return;

    try {
      await ref.read(friendServiceProvider).removeFriend(friend.uid);

      if (context.mounted) {
        AppNotifications.showSuccess(
          context: context,
          message: 'Usunięto znajomego: ${friend.displayName}',
        );
      }
    } catch (e) {
      if (context.mounted) {
        AppNotifications.showError(
          context: context,
          message: 'Błąd: $e',
        );
      }
    }
  }
}
