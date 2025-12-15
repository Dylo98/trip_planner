import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/core/theme/colors.dart';
import 'package:trip_planner/core/theme/text_style.dart';
import 'package:trip_planner/features/friends/providers/friends_provider.dart';
import 'package:trip_planner/features/friends/model/friend_model.dart';
import 'package:trip_planner/core/widgets/user_avatar.dart';

class DialogFriendSelector extends ConsumerWidget {
  const DialogFriendSelector({
    super.key,
    required this.tripId,
    required this.selectedFriendUid,
    required this.onChanged,
  });

  final String tripId;
  final String? selectedFriendUid;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendsAsync = ref.watch(friendsProvider);
    final sharedMembersAsync = ref.watch(sharedMembersProvider(tripId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Wybierz znajomego',
          style: AppTextStyles.bodyText,
        ),
        const SizedBox(height: 12),
        friendsAsync.when(
          data: (friends) {
            final sharedMembers = sharedMembersAsync.value ?? [];
            final sharedUids = sharedMembers.map((m) => m.uid).toSet();

            final uniqueFriendsMap = <String, Friend>{};
            for (final friend in friends) {
              uniqueFriendsMap[friend.uid] = friend;
            }
            final List<Friend> uniqueFriends = uniqueFriendsMap.values.toList();
            final List<Friend> availableFriends = uniqueFriends
                .where((f) => !sharedUids.contains(f.uid))
                .toList();

            if (friends.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Nie masz jeszcze znajomych.\nDodaj znajomych, aby móc udostępniać podróże.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyTextSecondary,
                ),
              );
            }

            if (availableFriends.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Wszyscy Twoi znajomi mają już dostęp do tej podróży.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyTextSecondary,
                ),
              );
            }

            final availableUids = availableFriends.map((f) => f.uid).toSet();

            return DropdownButtonFormField<String>(
              key: ValueKey(
                  'dropdown_${availableFriends.length}_${availableUids.join()}'),
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Znajomy',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              value: availableUids.contains(selectedFriendUid)
                  ? selectedFriendUid
                  : null,
              items: availableFriends.map((friend) {
                return DropdownMenuItem(
                  value: friend.uid,
                  child: FriendDropdownItem(friend: friend),
                );
              }).toList(),
              onChanged: onChanged,
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, __) => const Text(
            'Błąd podczas ładowania znajomych',
            style: TextStyle(color: AppColors.red),
          ),
        ),
      ],
    );
  }
}

class FriendDropdownItem extends ConsumerWidget {
  const FriendDropdownItem({
    super.key,
    required this.friend,
  });

  final Friend friend;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendDataAsync = ref.watch(friendDataProvider(friend.uid));

    return friendDataAsync.when(
      data: (friendData) {
        final avatarUrl = friendData?.avatar;
        final displayName = friendData?.name ?? friend.displayName;

        return Row(
          children: [
            UserAvatar(
              displayName: displayName,
              avatarUrl: avatarUrl,
              radius: 16,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                displayName,
                style: AppTextStyles.bodyText,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      },
      loading: () => Row(
        children: [
          UserAvatar(
            displayName: friend.displayName,
            radius: 16,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              friend.displayName,
              style: AppTextStyles.bodyText,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      error: (_, __) => Row(
        children: [
          UserAvatar(
            displayName: friend.displayName,
            radius: 16,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              friend.displayName,
              style: AppTextStyles.bodyText,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
