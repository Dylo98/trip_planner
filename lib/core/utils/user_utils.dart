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
}
