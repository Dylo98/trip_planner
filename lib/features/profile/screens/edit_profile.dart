import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/features/auth/controller/user_provider.dart';
import 'package:trip_planner/core/widgets/app_notifications.dart';
import 'package:trip_planner/core/theme/input_style.dart';
import 'package:trip_planner/core/theme/colors.dart';
import 'package:trip_planner/core/utils/validators.dart';
import 'package:trip_planner/core/utils/action_lock.dart';

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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: AppInputStyle.underlineInputDecoration(
                    labelText: 'Imię',
                    hintText: 'Podaj swoje imię',
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: Validators.validateName,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  initialValue: me?.email ?? '',
                  decoration: AppInputStyle.underlineInputDecoration(
                    labelText: 'Email',
                  ),
                  enabled: false,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 10),
                Text(
                  'Email nie może być zmieniony',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveProfile,
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
                            'Zapisz zmiany',
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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Błąd: $err'),
            ],
          ),
        ),
      ),
    );
  }
}
