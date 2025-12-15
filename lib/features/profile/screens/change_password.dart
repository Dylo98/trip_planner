import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:trip_planner/core/widgets/app_notifications.dart';

import 'package:trip_planner/core/theme/colors.dart';

import 'package:trip_planner/core/utils/validators.dart';

import 'package:trip_planner/core/utils/action_lock.dart';

import 'package:trip_planner/features/profile/providers/password_service_provider.dart';

import 'package:trip_planner/features/profile/widgets/change_password/password_text_field.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final ActionLock _lock = ActionLock();

  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Potwierdź nowe hasło';
    }

    if (value != _newPasswordController.text) {
      return 'Hasła nie są identyczne';
    }

    return null;
  }

  Future<void> _changePassword() {
    return _lock.run(() async {
      if (!_formKey.currentState!.validate()) return;

      setState(() => _isLoading = true);

      try {
        final passwordService = ref.read(passwordServiceProvider);

        await passwordService.changePassword(
          currentPassword: _currentPasswordController.text,
          newPassword: _newPasswordController.text,
        );

        if (mounted) {
          AppNotifications.showSuccess(
            context: context,
            message: 'Hasło zostało zmienione',
          );

          Navigator.of(context).pop();
        }
      } on FirebaseAuthException catch (e) {
        if (mounted) {
          final passwordService = ref.read(passwordServiceProvider);

          final message = passwordService.getFirebaseErrorMessage(e) ??
              'Błąd podczas zmiany hasła';

          AppNotifications.showError(context: context, message: message);
        }
      } catch (e) {
        if (mounted) {
          AppNotifications.showError(
            context: context,
            message: 'Błąd: $e',
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zmień hasło'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Aby zmienić hasło, wprowadź obecne hasło oraz nowe hasło.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 30),
              PasswordTextField(
                controller: _currentPasswordController,
                labelText: 'Obecne hasło',
                hintText: '••••••••',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Wprowadź obecne hasło';
                  }

                  return null;
                },
                enabled: !_isLoading,
              ),
              const SizedBox(height: 20),
              PasswordTextField(
                controller: _newPasswordController,
                labelText: 'Nowe hasło',
                hintText: '••••••••',
                validator: Validators.validatePassword,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 20),
              PasswordTextField(
                controller: _confirmPasswordController,
                labelText: 'Potwierdź nowe hasło',
                hintText: '••••••••',
                validator: _validateConfirmPassword,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _changePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Zmień hasło',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
