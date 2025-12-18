import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trip_planner/core/utils/user_utils.dart';
import 'package:trip_planner/features/friends/model/friend_model.dart';

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

  FriendRequest copyWith({
    String? fromUid,
    String? toUid,
    String? fromEmail,
    String? fromName,
    String? fromAvatar,
    FriendshipStatus? status,
    DateTime? createdAt,
  }) {
    return FriendRequest(
      id: id,
      fromUid: fromUid ?? this.fromUid,
      toUid: toUid ?? this.toUid,
      fromEmail: fromEmail ?? this.fromEmail,
      fromName: fromName ?? this.fromName,
      fromAvatar: fromAvatar ?? this.fromAvatar,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get displayName => UserUtils.formatDisplayName(fromName, fromEmail);

  bool get isPending => status == FriendshipStatus.pending;
  bool get isAccepted => status == FriendshipStatus.accepted;
  bool get isRejected => status == FriendshipStatus.rejected;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FriendRequest && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
