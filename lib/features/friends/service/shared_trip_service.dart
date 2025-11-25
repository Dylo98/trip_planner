import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trip_planner/features/trip/model/trip_model.dart';

enum TripRole {
  owner,
  editor,
  viewer,
}

class SharedTripMember {
  final String uid;
  final String email;
  final String? name;
  final String? avatar;
  final TripRole role;
  final DateTime addedAt;

  const SharedTripMember({
    required this.uid,
    required this.email,
    this.name,
    this.avatar,
    required this.role,
    required this.addedAt,
  });

  factory SharedTripMember.fromJson(String uid, Map<String, dynamic> json) {
    return SharedTripMember(
      uid: uid,
      email: json['email'] as String,
      name: json['name'] as String?,
      avatar: json['avatar'] as String?,
      role: TripRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => TripRole.viewer,
      ),
      addedAt: (json['addedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      if (name != null) 'name': name,
      if (avatar != null) 'avatar': avatar,
      'role': role.name,
      'addedAt': Timestamp.fromDate(addedAt),
    };
  }

  String get displayName => name ?? email.split('@').first;

  bool get canEdit => role == TripRole.owner || role == TripRole.editor;
  bool get isOwner => role == TripRole.owner;
}

class SharedTripService {
  SharedTripService({
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

  Future<void> shareTrip({
    required String tripId,
    required String friendUid,
    required TripRole role,
  }) async {
    final currentUid = _currentUserId;

    final tripDoc = await _firestore
        .collection('users')
        .doc(currentUid)
        .collection('trips')
        .doc(tripId)
        .get();

    if (!tripDoc.exists) {
      throw Exception('Podróż nie istnieje');
    }

    final friendDoc = await _firestore.collection('users').doc(friendUid).get();

    if (!friendDoc.exists) {
      throw Exception('Użytkownik nie istnieje');
    }

    final friendData = friendDoc.data()!;

    final member = SharedTripMember(
      uid: friendUid,
      email: friendData['email'],
      name: friendData['name'],
      avatar: friendData['avatar'],
      role: role,
      addedAt: DateTime.now(),
    );

    await _firestore
        .collection('users')
        .doc(currentUid)
        .collection('trips')
        .doc(tripId)
        .collection('shared_members')
        .doc(friendUid)
        .set(member.toJson());
    await _firestore
        .collection('users')
        .doc(friendUid)
        .collection('shared_trips')
        .doc(tripId)
        .set({
      'tripId': tripId,
      'ownerId': currentUid,
      'role': role.name,
      'sharedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeSharedAccess({
    required String tripId,
    required String memberUid,
  }) async {
    final currentUid = _currentUserId;

    final batch = _firestore.batch();

    batch.delete(
      _firestore
          .collection('users')
          .doc(currentUid)
          .collection('trips')
          .doc(tripId)
          .collection('shared_members')
          .doc(memberUid),
    );

    batch.delete(
      _firestore
          .collection('users')
          .doc(memberUid)
          .collection('shared_trips')
          .doc(tripId),
    );

    await batch.commit();
  }

  Future<void> updateMemberRole({
    required String tripId,
    required String memberUid,
    required TripRole newRole,
  }) async {
    final currentUid = _currentUserId;

    await _firestore
        .collection('users')
        .doc(currentUid)
        .collection('trips')
        .doc(tripId)
        .collection('shared_members')
        .doc(memberUid)
        .update({'role': newRole.name});

    await _firestore
        .collection('users')
        .doc(memberUid)
        .collection('shared_trips')
        .doc(tripId)
        .update({'role': newRole.name});
  }

  Stream<List<SharedTripMember>> watchSharedMembers(String tripId) {
    final currentUid = _currentUserId;

    return _firestore
        .collection('users')
        .doc(currentUid)
        .collection('trips')
        .doc(tripId)
        .collection('shared_members')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => SharedTripMember.fromJson(doc.id, doc.data()))
          .toList();
    });
  }

  Stream<List<Trip>> watchSharedTripsForMe() {
    final currentUid = _currentUserId;

    return _firestore
        .collection('users')
        .doc(currentUid)
        .collection('shared_trips')
        .snapshots()
        .asyncMap((snapshot) async {
      final trips = <Trip>[];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final ownerId = data['ownerId'] as String;
        final tripId = data['tripId'] as String;

        final tripDoc = await _firestore
            .collection('users')
            .doc(ownerId)
            .collection('trips')
            .doc(tripId)
            .get();

        if (tripDoc.exists && tripDoc.data() != null) {
          final tripData = Map<String, dynamic>.from(tripDoc.data()!);

          tripData['id'] = tripId;

          try {
            final trip = Trip.fromFirestore(tripData);
            trips.add(trip);
          } catch (e) {
            //
          }
        }
      }
      return trips;
    });
  }

  Future<SharedTripMember?> getMyAccessToTrip(
      String tripId, String ownerId) async {
    final currentUid = _currentUserId;

    final doc = await _firestore
        .collection('users')
        .doc(ownerId)
        .collection('trips')
        .doc(tripId)
        .collection('shared_members')
        .doc(currentUid)
        .get();

    if (!doc.exists) return null;

    return SharedTripMember.fromJson(doc.id, doc.data()!);
  }

  Future<bool> canEditTrip(String tripId, String ownerId) async {
    final currentUid = _currentUserId;

    if (ownerId == currentUid) return true;

    final access = await getMyAccessToTrip(tripId, ownerId);
    return access?.canEdit ?? false;
  }
}
