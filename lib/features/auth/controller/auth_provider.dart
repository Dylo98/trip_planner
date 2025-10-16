import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/features/auth/services/auth_service.dart';

final authProvider = Provider<AuthService>((ref) {
  return AuthService();
});
