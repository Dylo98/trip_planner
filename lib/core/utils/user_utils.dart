import 'package:firebase_auth/firebase_auth.dart';

class UserUtils {
  UserUtils._();

  static String getDisplayName(User? user) {
    if (user?.displayName != null && user!.displayName!.trim().isNotEmpty) {
      return user.displayName!.trim();
    }

    final email = user?.email;
    if (email != null && email.contains('@')) {
      return email.split('@').first;
    }

    return 'Użytkownik';
  }

  static String getAvatarUrl(User? user) {
    return user?.photoURL ?? '';
  }

  /// Generuje nazwę wyświetlaną z imienia lub emaila
  /// Używane przez modele: Friend, FriendRequest, SharedTripMember
  static String formatDisplayName(String? name, String email) {
    if (name != null && name.trim().isNotEmpty) {
      return name.trim();
    }
    return email.split('@').first;
  }
}
