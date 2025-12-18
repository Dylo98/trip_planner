import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trip_planner/core/utils/user_utils.dart';

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

  String get displayName => UserUtils.formatDisplayName(name, email);

  bool get canEdit => role == TripRole.owner || role == TripRole.editor;
  bool get isOwner => role == TripRole.owner;
  bool get isEditor => role == TripRole.editor;
  bool get isViewer => role == TripRole.viewer;

  SharedTripMember copyWith({
    String? email,
    String? name,
    String? avatar,
    TripRole? role,
    DateTime? addedAt,
  }) {
    return SharedTripMember(
      uid: uid,
      email: email ?? this.email,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      role: role ?? this.role,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SharedTripMember && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;
}
