import 'package:flutter/material.dart';
import 'package:trip_planner/core/theme/colors.dart';
import 'package:trip_planner/core/theme/text_style.dart';
import 'package:trip_planner/features/friends/model/shared_trip_member_model.dart';
import 'package:trip_planner/features/friends/widgets/dialog/dialog_components/dialog_role_badge.dart';

class DialogSharedMemberItem extends StatelessWidget {
  const DialogSharedMemberItem({
    super.key,
    required this.member,
    required this.onChangeRole,
    required this.onRemove,
  });

  final SharedTripMember member;
  final VoidCallback onChangeRole;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: AppColors.limeSlice,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.limeSliceDark.withValues(alpha: 0.1),
          backgroundImage: member.avatar != null && member.avatar!.isNotEmpty
              ? NetworkImage(member.avatar!)
              : null,
          child: member.avatar == null || member.avatar!.isEmpty
              ? Text(
                  member.displayName[0].toUpperCase(),
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.limeSliceDark),
                )
              : null,
        ),
        title: Text(
          member.displayName,
          style: AppTextStyles.bodyText,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            DialogRoleBadge(role: member.role),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: AppColors.limeSliceDark),
          onSelected: (value) {
            if (value == 'change_role') {
              onChangeRole();
            } else if (value == 'remove') {
              onRemove();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'change_role',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Zmień uprawnienia', style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'remove',
              child: Row(
                children: [
                  Icon(Icons.person_remove, color: AppColors.red),
                  SizedBox(width: 8),
                  Text(
                    'Usuń dostęp',
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
