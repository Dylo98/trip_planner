import 'package:flutter/material.dart';
import 'package:trip_planner/core/theme/colors.dart';
import 'package:trip_planner/core/theme/text_style.dart';
import 'package:trip_planner/core/widgets/user_avatar.dart';
import 'package:trip_planner/features/friends/model/friend_request_model.dart';

class FriendRequestItem extends StatelessWidget {
  const FriendRequestItem({
    super.key,
    required this.request,
    required this.onAccept,
    required this.onReject,
  });

  final FriendRequest request;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: AppColors.limeSlice,
      child: ListTile(
        leading: UserAvatar(
          displayName: request.displayName,
          avatarUrl: request.fromAvatar,
        ),
        title: Text(
          request.displayName,
          style: AppTextStyles.bodyText,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(request.fromEmail, style: AppTextStyles.bodyTextSecondary),
            const SizedBox(height: 4),
            Text(
              'Wysłano: ${_formatDate(request.createdAt)}',
              style: AppTextStyles.bodyTextSecondary,
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.check, color: AppColors.primary),
              onPressed: onAccept,
            ),
            IconButton(
              icon: const Icon(Icons.close, color: AppColors.red),
              onPressed: onReject,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return 'Przed chwilą';
      }
      return 'Dzisiaj';
    } else if (difference.inDays == 1) {
      return 'Wczoraj';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} dni temu';
    } else {
      return '${date.day}.${date.month}.${date.year}';
    }
  }
}
