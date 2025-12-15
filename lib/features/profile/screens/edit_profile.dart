import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trip_planner/features/auth/providers/user_provider.dart';

import 'package:trip_planner/core/widgets/app_notifications.dart';

import 'package:trip_planner/core/utils/action_lock.dart';

import 'package:trip_planner/core/widgets/loading_indicator.dart';

import 'package:trip_planner/core/widgets/error_display.dart';

import 'package:trip_planner/features/profile/widgets/edit_profile/edit_profile_form.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();

  bool _isLoading = false;

  final ActionLock _lock = ActionLock();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final me = ref.read(meProvider).value;

      if (me != null) {
        _nameController.text = me.name ?? '';
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();

    super.dispose();
  }

  Future<void> _saveProfile() {
    return _lock.run(() async {
      if (!_formKey.currentState!.validate()) return;

      setState(() => _isLoading = true);

      try {
        final userRepository = ref.read(userRepositoryProvider);

        await userRepository.updateProfile(
          name: _nameController.text.trim(),
        );

        ref.invalidate(meProvider);

        if (mounted) {
          AppNotifications.showSuccess(
            context: context,
            message: 'Profil został zaktualizowany',
          );

          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          AppNotifications.showError(
            context: context,
            message: 'Błąd podczas zapisywania profilu: $e',
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
    final meAsync = ref.watch(meProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edytuj profil'),
        elevation: 0,
      ),
      body: meAsync.when(
        data: (me) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: EditProfileForm(
            formKey: _formKey,
            nameController: _nameController,
            email: me?.email ?? '',
            isLoading: _isLoading,
            onSave: _saveProfile,
          ),
        ),
        loading: () => const LoadingIndicator(),
        error: (err, stack) => ErrorDisplay(
          message: 'Błąd: $err',
          onRetry: () => ref.invalidate(meProvider),
        ),
      ),
    );
  }
}
