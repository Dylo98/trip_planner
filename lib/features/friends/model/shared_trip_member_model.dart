import 'package:cloud_firestore/cloud_firestore.dart';

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
