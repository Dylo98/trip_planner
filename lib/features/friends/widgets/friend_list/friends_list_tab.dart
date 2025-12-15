import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/core/widgets/app_notifications.dart';
import 'package:trip_planner/core/widgets/dialog/dialog_confirmation.dart';
import 'package:trip_planner/core/widgets/error_display.dart';
import 'package:trip_planner/core/widgets/loading_indicator.dart';
import 'package:trip_planner/features/friends/providers/friends_provider.dart';
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
      loading: () => const LoadingIndicator(
        message: 'Ładowanie znajomych...',
      ),
      error: (error, stack) => ErrorDisplay(
        message: 'Błąd podczas ładowania znajomych.',
        onRetry: () => ref.invalidate(friendsProvider),
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
          message: 'Usunięto znajomego ${friend.displayName}',
        );
      }
    } catch (e) {
      if (context.mounted) {
        AppNotifications.showError(
          context: context,
          message:
              'Wystąpił błąd podczas usuwania znajomego ${friend.displayName}',
        );
      }
    }
  }
}
