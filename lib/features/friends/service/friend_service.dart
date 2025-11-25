import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trip_planner/features/friends/model/friend_model.dart';

class FriendService {
  FriendService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String get _currentUserId {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Użytkownik niezalogowany');
    return uid;
  }

  Future<Map<String, dynamic>?> findUserByEmail(String email) async {
    final querySnapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: email.trim().toLowerCase())
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) return null;

    final doc = querySnapshot.docs.first;
    return {
      'uid': doc.id,
      ...doc.data(),
    };
  }

  Future<void> sendFriendRequest(String targetEmail) async {
    final currentUid = _currentUserId;

    final currentUserDoc =
        await _firestore.collection('users').doc(currentUid).get();
    if (!currentUserDoc.exists) {
      throw Exception('Nie znaleziono danych użytkownika');
    }

    final currentUserData = currentUserDoc.data()!;

    final targetUser = await findUserByEmail(targetEmail);
    if (targetUser == null) {
      throw Exception('Nie znaleziono użytkownika o emailu: $targetEmail');
    }

    final targetUid = targetUser['uid'] as String;

    if (targetUid == currentUid) {
      throw Exception('Nie możesz dodać siebie jako znajomego');
    }

    final existingFriendship = await _firestore
        .collection('users')
        .doc(currentUid)
        .collection('friends')
        .doc(targetUid)
        .get();

    if (existingFriendship.exists) {
      final status = existingFriendship.data()?['status'];
      if (status == 'accepted') {
        throw Exception('Ten użytkownik jest już Twoim znajomym');
      } else if (status == 'pending') {
        throw Exception('Zaproszenie zostało już wysłane');
      }
    }

    final reverseRequest = await _firestore
        .collection('users')
        .doc(targetUid)
        .collection('friend_requests')
        .where('fromUid', isEqualTo: currentUid)
        .where('status', isEqualTo: 'pending')
        .get();

    if (reverseRequest.docs.isNotEmpty) {
      throw Exception('To zaproszenie już istnieje');
    }

    final request = FriendRequest(
      id: '',
      fromUid: currentUid,
      toUid: targetUid,
      fromEmail: currentUserData['email'],
      fromName: currentUserData['name'],
      fromAvatar: currentUserData['avatar'],
      status: FriendshipStatus.pending,
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection('users')
        .doc(targetUid)
        .collection('friend_requests')
        .add(request.toJson());
  }

  Future<void> acceptFriendRequest(String requestId, String fromUid) async {
    final currentUid = _currentUserId;

    final currentUserDoc =
        await _firestore.collection('users').doc(currentUid).get();
    final friendUserDoc =
        await _firestore.collection('users').doc(fromUid).get();

    if (!currentUserDoc.exists || !friendUserDoc.exists) {
      throw Exception('Nie znaleziono danych użytkownika');
    }

    final currentUserData = currentUserDoc.data()!;
    final friendUserData = friendUserDoc.data()!;

    final batch = _firestore.batch();

    batch.update(
      _firestore
          .collection('users')
          .doc(currentUid)
          .collection('friend_requests')
          .doc(requestId),
      {'status': 'accepted'},
    );

    final currentUserFriend = Friend(
      uid: fromUid,
      email: friendUserData['email'],
      name: friendUserData['name'],
      avatar: friendUserData['avatar'],
      status: FriendshipStatus.accepted,
      createdAt: DateTime.now(),
    );

    batch.set(
      _firestore
          .collection('users')
          .doc(currentUid)
          .collection('friends')
          .doc(fromUid),
      currentUserFriend.toJson(),
    );

    final friendUserFriend = Friend(
      uid: currentUid,
      email: currentUserData['email'],
      name: currentUserData['name'],
      avatar: currentUserData['avatar'],
      status: FriendshipStatus.accepted,
      createdAt: DateTime.now(),
    );

    batch.set(
      _firestore
          .collection('users')
          .doc(fromUid)
          .collection('friends')
          .doc(currentUid),
      friendUserFriend.toJson(),
    );

    await batch.commit();
  }

  Future<void> rejectFriendRequest(String requestId) async {
    final currentUid = _currentUserId;

    await _firestore
        .collection('users')
        .doc(currentUid)
        .collection('friend_requests')
        .doc(requestId)
        .update({'status': 'rejected'});
  }

  Future<void> removeFriend(String friendUid) async {
    final currentUid = _currentUserId;

    final batch = _firestore.batch();

    batch.delete(
      _firestore
          .collection('users')
          .doc(currentUid)
          .collection('friends')
          .doc(friendUid),
    );

    batch.delete(
      _firestore
          .collection('users')
          .doc(friendUid)
          .collection('friends')
          .doc(currentUid),
    );

    await batch.commit();
  }

  Stream<List<Friend>> watchFriends() {
    final currentUid = _currentUserId;

    return _firestore
        .collection('users')
        .doc(currentUid)
        .collection('friends')
        .where('status', isEqualTo: 'accepted')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Friend.fromJson(doc.id, doc.data()))
          .toList();
    });
  }

  Stream<List<FriendRequest>> watchFriendRequests() {
    final currentUid = _currentUserId;

    return _firestore
        .collection('users')
        .doc(currentUid)
        .collection('friend_requests')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => FriendRequest.fromJson(doc.id, doc.data()))
          .toList();
    });
  }

  Future<List<Friend>> getFriends() async {
    final currentUid = _currentUserId;

    final snapshot = await _firestore
        .collection('users')
        .doc(currentUid)
        .collection('friends')
        .where('status', isEqualTo: 'accepted')
        .get();

    return snapshot.docs
        .map((doc) => Friend.fromJson(doc.id, doc.data()))
        .toList();
  }
}
