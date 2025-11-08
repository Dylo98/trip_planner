class AppUser {
  final String uid;
  final String email;
  final String? name;
  final String? avatar;
  final String? coverImage;

  const AppUser({
    required this.uid,
    required this.email,
    this.name,
    this.avatar,
    this.coverImage,
  });

  AppUser copyWith({
    String? email,
    String? name,
    String? avatar,
    String? coverImage,
  }) {
    return AppUser(
      uid: uid,
      email: email ?? this.email,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      coverImage: coverImage ?? this.coverImage,
    );
  }

  factory AppUser.fromJson(String uid, Map<String, dynamic> json) {
    return AppUser(
      uid: uid,
      email: json['email'] as String,
      name: json['name'] as String?,
      avatar: json['avatar'] as String?,
      coverImage: json['coverImage'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      if (name != null) 'name': name,
      if (avatar != null) 'avatar': avatar,
      if (coverImage != null) 'coverImage': coverImage,
    };
  }
}
