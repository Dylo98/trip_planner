import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/features/friends/controller/friends_provider.dart';
import 'package:trip_planner/core/widgets/app_notifications.dart';
import 'package:trip_planner/core/utils/action_lock.dart';

class FriendRequestsTab extends ConsumerStatefulWidget {
  const FriendRequestsTab({super.key});

  @override
  ConsumerState<FriendRequestsTab> createState() => _FriendRequestsTabState();
}

class _FriendRequestsTabState extends ConsumerState<FriendRequestsTab> {
  final _actionLock = ActionLock();

  @override
  Widget build(BuildContext context) {
    final requestsAsync = ref.watch(friendRequestsProvider);

    return requestsAsync.when(
      data: (requests) {
        if (requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.mail_outline,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Brak zaproszeń',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tutaj zobaczysz zaproszenia do znajomych',
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
          itemCount: requests.length,
          padding: const EdgeInsets.all(8),
          itemBuilder: (context, index) {
            final request = requests[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  backgroundImage: request.fromAvatar != null &&
                          request.fromAvatar!.isNotEmpty
                      ? NetworkImage(request.fromAvatar!)
                      : null,
                  child:
                      request.fromAvatar == null || request.fromAvatar!.isEmpty
                          ? Text(
                              request.displayName[0].toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            )
                          : null,
                ),
                title: Text(
                  request.displayName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(request.fromEmail),
                    const SizedBox(height: 4),
                    Text(
                      'Wysłano: ${_formatDate(request.createdAt)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      tooltip: 'Akceptuj',
                      onPressed: () => _handleAccept(request),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      tooltip: 'Odrzuć',
                      onPressed: () => _handleReject(request),
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
            const Text('Błąd podczas ładowania zaproszeń'),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => ref.invalidate(friendRequestsProvider),
              child: const Text('Spróbuj ponownie'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAccept(request) async {
    await _actionLock.run(() async {
      try {
        await ref
            .read(friendServiceProvider)
            .acceptFriendRequest(request.id, request.fromUid);

        if (mounted) {
          AppNotifications.showSuccess(
            context: context,
            message: 'Dodano znajomego: ${request.displayName}',
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

  Future<void> _handleReject(request) async {
    await _actionLock.run(() async {
      try {
        await ref.read(friendServiceProvider).rejectFriendRequest(request.id);

        if (mounted) {
          AppNotifications.showSuccess(
            context: context,
            message: 'Odrzucono zaproszenie od: ${request.displayName}',
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
