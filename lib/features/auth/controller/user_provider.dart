import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../model/app_user.dart';
import '../services/user_repository.dart';

final userRepositoryProvider =
    Provider<UserRepository>((ref) => UserRepository());

final authStateProvider = StreamProvider<fb.User?>(
  (ref) => fb.FirebaseAuth.instance.authStateChanges(),
);

final meProvider = StreamProvider.autoDispose<AppUser?>((ref) {
  final uid = ref.watch(authStateProvider).value?.uid;
  if (uid == null) return const Stream.empty();
  final firestore = FirebaseFirestore.instance;
  return firestore.collection('users').doc(uid).snapshots().map((snap) {
    if (!snap.exists) return null;
    return AppUser.fromJson(uid, snap.data()!);
  });
});
