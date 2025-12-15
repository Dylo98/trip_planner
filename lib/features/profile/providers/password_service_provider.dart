import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/features/profile/services/password_service.dart';

final passwordServiceProvider = Provider<PasswordService>((ref) {
  return PasswordService();
});
