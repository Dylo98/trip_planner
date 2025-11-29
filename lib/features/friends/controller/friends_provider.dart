import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/features/friends/model/friend_model.dart';
import 'package:trip_planner/features/friends/model/friend_request_model.dart';
import 'package:trip_planner/features/friends/model/shared_trip_member_model.dart';
import 'package:trip_planner/features/friends/service/friend_service.dart';
import 'package:trip_planner/features/friends/service/shared_trip_service.dart';
import 'package:trip_planner/features/trip/model/trip_model.dart';
import 'package:trip_planner/features/auth/model/app_user.dart';
import 'package:trip_planner/features/auth/services/user_repository.dart';

final friendServiceProvider = Provider<FriendService>((ref) {
  return FriendService();
});

final sharedTripServiceProvider = Provider<SharedTripService>((ref) {
  return SharedTripService();
});

final friendsProvider = StreamProvider.autoDispose<List<Friend>>((ref) {
  final service = ref.watch(friendServiceProvider);
  return service.watchFriends();
});

final friendRequestsProvider =
    StreamProvider.autoDispose<List<FriendRequest>>((ref) {
  final service = ref.watch(friendServiceProvider);
  return service.watchFriendRequests();
});

final sharedTripsProvider = StreamProvider.autoDispose<List<Trip>>((ref) {
  final service = ref.watch(sharedTripServiceProvider);
  return service.watchSharedTripsForMe();
});

final sharedMembersProvider = StreamProvider.autoDispose
    .family<List<SharedTripMember>, String>((ref, tripId) {
  final service = ref.watch(sharedTripServiceProvider);
  return service.watchSharedMembers(tripId);
});

final pendingRequestsCountProvider = StreamProvider.autoDispose<int>((ref) {
  return ref.watch(friendRequestsProvider.stream).map((requests) {
    return requests.length;
  });
});

final friendDataProvider =
    StreamProvider.autoDispose.family<AppUser?, String>((ref, uid) {
  final repository = UserRepository();
  return repository.watchUser(uid);
});
