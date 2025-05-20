class User {
  final String id;
  final String email;
  final String? displayName;
  final String? photoURL;

  User({
    required this.id,
    required this.email,
    this.displayName,
    this.photoURL,
  });

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoURL,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
    );
  }
}
