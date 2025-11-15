import 'package:cloud_firestore/cloud_firestore.dart';

enum FriendshipStatus {
  pending,
  accepted,
  rejected,
  blocked,
}

class Friend {
  final String uid;
  final String email;
  final String? name;
  final String? avatar;
  final FriendshipStatus status;
  final DateTime createdAt;

  const Friend({
    required this.uid,
    required this.email,
    this.name,
    this.avatar,
    required this.status,
    required this.createdAt,
  });

  factory Friend.fromJson(String uid, Map<String, dynamic> json) {
    return Friend(
      uid: uid,
      email: json['email'] as String,
      name: json['name'] as String?,
      avatar: json['avatar'] as String?,
      status: FriendshipStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => FriendshipStatus.pending,
      ),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      if (name != null) 'name': name,
      if (avatar != null) 'avatar': avatar,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Friend copyWith({
    String? email,
    String? name,
    String? avatar,
    FriendshipStatus? status,
    DateTime? createdAt,
  }) {
    return Friend(
      uid: uid,
      email: email ?? this.email,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get displayName => name ?? email.split('@').first;

  bool get isAccepted => status == FriendshipStatus.accepted;
  bool get isPending => status == FriendshipStatus.pending;
  bool get isRejected => status == FriendshipStatus.rejected;
  bool get isBlocked => status == FriendshipStatus.blocked;
}

class FriendRequest {
  final String id;
  final String fromUid;
  final String toUid;
  final String fromEmail;
  final String? fromName;
  final String? fromAvatar;
  final FriendshipStatus status;
  final DateTime createdAt;

  const FriendRequest({
    required this.id,
    required this.fromUid,
    required this.toUid,
    required this.fromEmail,
    this.fromName,
    this.fromAvatar,
    required this.status,
    required this.createdAt,
  });

  factory FriendRequest.fromJson(String id, Map<String, dynamic> json) {
    return FriendRequest(
      id: id,
      fromUid: json['fromUid'] as String,
      toUid: json['toUid'] as String,
      fromEmail: json['fromEmail'] as String,
      fromName: json['fromName'] as String?,
      fromAvatar: json['fromAvatar'] as String?,
      status: FriendshipStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => FriendshipStatus.pending,
      ),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fromUid': fromUid,
      'toUid': toUid,
      'fromEmail': fromEmail,
      if (fromName != null) 'fromName': fromName,
      if (fromAvatar != null) 'fromAvatar': fromAvatar,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  String get displayName => fromName ?? fromEmail.split('@').first;
}
