import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/core/widgets/app_notifications.dart';
import 'package:trip_planner/features/friends/controller/friends_provider.dart';
import 'package:trip_planner/features/friends/service/shared_trip_service.dart';
import 'package:trip_planner/core/utils/action_lock.dart';

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
              Icon(Icons.people, color: Colors.blue),
              SizedBox(width: 8),
              Text('Współwłaściciele'),
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
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Nie udostępniłeś tej podróży\nżadnemu znajomemu',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
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
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      backgroundImage:
                          member.avatar != null && member.avatar!.isNotEmpty
                              ? NetworkImage(member.avatar!)
                              : null,
                      child: member.avatar == null || member.avatar!.isEmpty
                          ? Text(
                              member.displayName[0].toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            )
                          : null,
                    ),
                    title: Text(
                      member.displayName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(member.email),
                        const SizedBox(height: 4),
                        _buildRoleBadge(member.role),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: (value) async {
                        if (value == 'change_role') {
                          await _showChangeRoleDialog(member);
                        } else if (value == 'remove') {
                          await _confirmRemoveMember(member);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'change_role',
                          child: Row(
                            children: [
                              Icon(Icons.edit),
                              SizedBox(width: 8),
                              Text('Zmień uprawnienia'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'remove',
                          child: Row(
                            children: [
                              Icon(Icons.person_remove, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                'Usuń dostęp',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
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
              style: TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Zamknij'),
        ),
      ],
    );
  }

  Widget _buildRoleBadge(TripRole role) {
    final color = role == TripRole.editor ? Colors.green : Colors.blue;
    final text = role == TripRole.editor ? 'Edytor' : 'Widz';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<void> _showChangeRoleDialog(SharedTripMember member) async {
    final newRole = await showDialog<TripRole>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Zmień uprawnienia: ${member.displayName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.green),
              title: const Text('Edytor'),
              subtitle: const Text('Może dodawać i edytować punkty'),
              trailing: member.role == TripRole.editor
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () => Navigator.pop(context, TripRole.editor),
            ),
            ListTile(
              leading: const Icon(Icons.visibility, color: Colors.blue),
              title: const Text('Widz'),
              subtitle: const Text('Tylko podgląd podróży'),
              trailing: member.role == TripRole.viewer
                  ? const Icon(Icons.check, color: Colors.blue)
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Usuń dostęp'),
        content: Text(
          'Czy na pewno chcesz usunąć dostęp dla ${member.displayName}?\n\n'
          'Ta osoba nie będzie już mogła przeglądać ani edytować tej podróży.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Anuluj'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Usuń'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

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
