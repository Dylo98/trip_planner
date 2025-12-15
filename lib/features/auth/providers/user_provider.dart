import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../model/app_user.dart';
import '../services/user_repository.dart';

final userRepositoryProvider =
    Provider<UserRepository>((ref) => UserRepository());

final authStateProvider = StreamProvider<fb.User?>(
  (ref) => fb.FirebaseAuth.instance.authStateChanges(),
);

final meProvider = StreamProvider.autoDispose<AppUser?>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return repository.watchMe();
});
