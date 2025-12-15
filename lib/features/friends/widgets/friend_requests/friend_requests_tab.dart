import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/core/utils/action_lock.dart';
import 'package:trip_planner/core/widgets/app_notifications.dart';
import 'package:trip_planner/core/widgets/error_display.dart';
import 'package:trip_planner/core/widgets/loading_indicator.dart';
import 'package:trip_planner/features/friends/providers/friends_provider.dart';
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
      loading: () => const LoadingIndicator(
        message: 'Ładowanie zaproszeń...',
      ),
      error: (error, stack) => ErrorDisplay(
        message: 'Błąd podczas ładowania zaproszeń.',
        onRetry: () => ref.invalidate(friendRequestsProvider),
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
            message: 'Dodano znajomego ${request.displayName}',
          );
        }
      } catch (e) {
        if (mounted) {
          AppNotifications.showError(
            context: context,
            message: 'Wystąpił błąd przy dodawaniu znajomego',
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
            message: 'Odrzucono zaproszenie od ${request.displayName}',
          );
        }
      } catch (e) {
        if (mounted) {
          AppNotifications.showError(
            context: context,
            message: 'Wystąpił błąd',
          );
        }
      }
    });
  }
}
