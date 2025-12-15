import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/core/theme/colors.dart';
import 'package:trip_planner/core/theme/text_style.dart';
import 'package:trip_planner/features/friends/model/friend_model.dart';
import 'package:trip_planner/features/friends/providers/friends_provider.dart';
import 'package:trip_planner/core/widgets/user_avatar.dart';

class FriendListItem extends ConsumerWidget {
  const FriendListItem({
    super.key,
    required this.friend,
    required this.onRemove,
  });

  final Friend friend;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendDataAsync = ref.watch(friendDataProvider(friend.uid));

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: AppColors.limeSlice,
      child: ListTile(
        leading: friendDataAsync.when(
          data: (friendData) {
            final avatarUrl = friendData?.avatar;
            final displayName = friendData?.name ?? friend.displayName;

            return UserAvatar(
              displayName: displayName,
              avatarUrl: avatarUrl,
            );
          },
          loading: () => UserAvatar(
            displayName: friend.displayName,
          ),
          error: (_, __) => UserAvatar(
            displayName: friend.displayName,
          ),
        ),
        title: friendDataAsync.maybeWhen(
          data: (friendData) => Text(
            friendData?.name ?? friend.displayName,
            style: AppTextStyles.bodyText,
          ),
          orElse: () => Text(
            friend.displayName,
            style: AppTextStyles.bodyText,
          ),
        ),
        subtitle: Text(
          friend.email,
          style: AppTextStyles.bodyTextSecondary,
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            if (value == 'remove') {
              onRemove();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'remove',
              child: Row(
                children: [
                  Icon(Icons.person_remove, color: AppColors.red),
                  SizedBox(width: 8),
                  Text(
                    'Usuń znajomego',
                    style: AppTextStyles.bodySmallRed,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
