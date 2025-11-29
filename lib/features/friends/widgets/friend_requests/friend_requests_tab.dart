import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/core/utils/action_lock.dart';
import 'package:trip_planner/core/widgets/app_notifications.dart';
import 'package:trip_planner/features/friends/controller/friends_provider.dart';
import 'package:trip_planner/features/friends/model/friend_request_model.dart';
import 'package:trip_planner/features/friends/widgets/friend_requests/friend_request_item.dart';
import 'package:trip_planner/features/friends/widgets/friend_requests/friend_requests_empty_state.dart';

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
          return const FriendRequestsEmptyState();
        }

        return ListView.builder(
          itemCount: requests.length,
          padding: const EdgeInsets.all(8),
          itemBuilder: (context, index) {
            final request = requests[index];
            return FriendRequestItem(
              request: request,
              onAccept: () => _handleAccept(request),
              onReject: () => _handleReject(request),
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

  Future<void> _handleAccept(FriendRequest request) async {
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

  Future<void> _handleReject(FriendRequest request) async {
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
}
