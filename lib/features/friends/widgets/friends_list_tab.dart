import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/features/friends/controller/friends_provider.dart';
import 'package:trip_planner/features/friends/service/friend_service.dart';
import 'package:trip_planner/core/widgets/app_notifications.dart';

class FriendsListTab extends ConsumerWidget {
  const FriendsListTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendsAsync = ref.watch(friendsProvider);

    return friendsAsync.when(
      data: (friends) {
        if (friends.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Nie masz jeszcze znajomych',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Dodaj znajomych, aby dzielić się podróżami',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: friends.length,
          padding: const EdgeInsets.all(8),
          itemBuilder: (context, index) {
            final friend = friends[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  backgroundImage:
                      friend.avatar != null && friend.avatar!.isNotEmpty
                          ? NetworkImage(friend.avatar!)
                          : null,
                  child: friend.avatar == null || friend.avatar!.isEmpty
                      ? Text(
                          friend.displayName[0].toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        )
                      : null,
                ),
                title: Text(
                  friend.displayName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(friend.email),
                trailing: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) async {
                    if (value == 'remove') {
                      await _confirmRemoveFriend(context, ref, friend);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'remove',
                      child: Row(
                        children: [
                          Icon(Icons.person_remove, color: Colors.red),
                          SizedBox(width: 8),
                          Text(
                            'Usuń znajomego',
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
    friend,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Usuń znajomego'),
        content: Text(
          'Czy na pewno chcesz usunąć ${friend.displayName} z listy znajomych?',
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

    if (confirmed != true || !context.mounted) return;

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
