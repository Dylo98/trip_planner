import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trip_planner/core/theme/colors.dart';
import 'dart:io';
import 'package:trip_planner/features/auth/providers/user_provider.dart';
import 'package:trip_planner/features/auth/providers/auth_provider.dart';
import 'package:trip_planner/features/profile/services/profile_image_service.dart';
import 'package:trip_planner/core/widgets/app_notifications.dart';
import 'package:trip_planner/core/utils/action_lock.dart';
import 'package:trip_planner/core/widgets/error_display.dart';
import 'package:trip_planner/core/widgets/loading_indicator.dart';
import 'package:trip_planner/features/profile/widgets/profile_header/profile_header.dart';
import 'package:trip_planner/features/profile/widgets/profile_menu/profile_info.dart';
import 'package:trip_planner/features/profile/widgets/profile_menu/profile_menu.dart';
import 'package:trip_planner/features/profile/widgets/profile_menu/logout_dialog.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  final ProfileImageService _profileImageService = ProfileImageService();

  final ActionLock _avatarLock = ActionLock();
  final ActionLock _coverLock = ActionLock();
  final ActionLock _logoutLock = ActionLock();

  File? _selectedProfileImage;
  File? _selectedCoverImage;
  bool _isUpdating = false;

  Future<void> _pickProfileImage() async {
    if (_isUpdating || _avatarLock.isBusy) return;

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() => _selectedProfileImage = File(image.path));
        await _uploadProfileImage(_selectedProfileImage!);
      }
    } catch (e) {
      if (mounted) {
        AppNotifications.showError(
          context: context,
          message: 'Nie udało się wybrać zdjęcia',
        );
      }
    }
  }

  Future<void> _pickCoverImage() async {
    if (_isUpdating || _coverLock.isBusy) return;

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 600,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() => _selectedCoverImage = File(image.path));
        await _uploadCoverImage(_selectedCoverImage!);
      }
    } catch (e) {
      if (mounted) {
        AppNotifications.showError(
          context: context,
          message: 'Nie udało się wybrać zdjęcia',
        );
      }
    }
  }

  Future<void> _uploadProfileImage(File imageFile) {
    return _avatarLock.run(() async {
      if (!mounted) return;
      setState(() => _isUpdating = true);

      try {
        await _profileImageService.uploadAvatar(imageFile);

        if (mounted) {
          setState(() => _selectedProfileImage = null);
          ref.invalidate(meProvider);

          AppNotifications.showSuccess(
            context: context,
            message: 'Zdjęcie profilowe zostało zaktualizowane',
          );
        }
      } catch (e) {
        if (mounted) {
          final message = _profileImageService.getErrorMessage(e);
          AppNotifications.showError(
            context: context,
            message: message,
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isUpdating = false);
        }
      }
    });
  }

  Future<void> _uploadCoverImage(File imageFile) {
    return _coverLock.run(() async {
      if (!mounted) return;
      setState(() => _isUpdating = true);

      try {
        await _profileImageService.uploadCoverImage(imageFile);

        if (mounted) {
          setState(() => _selectedCoverImage = null);
          ref.invalidate(meProvider);

          AppNotifications.showSuccess(
            context: context,
            message: 'Zdjęcie w tle zostało zaktualizowane',
          );
        }
      } catch (e) {
        if (mounted) {
          final message = _profileImageService.getErrorMessage(e);
          AppNotifications.showError(
            context: context,
            message: message,
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isUpdating = false);
        }
      }
    });
  }

  Future<void> _logout() {
    return _logoutLock.run(() async {
      try {
        final authService = ref.read(authProvider);
        await authService.logout();

        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } catch (e) {
        if (mounted) {
          AppNotifications.showError(
            context: context,
            message: 'Nie udało się wylogować',
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final meAsync = ref.watch(meProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
      ),
      body: Stack(
        children: [
          meAsync.when(
            data: (me) => SingleChildScrollView(
              child: Column(
                children: [
                  ProfileHeader(
                    coverImageUrl: me?.coverImage,
                    avatarUrl: me?.avatar,
                    selectedCoverImage: _selectedCoverImage,
                    selectedProfileImage: _selectedProfileImage,
                    onCoverImageTap: _pickCoverImage,
                    onProfileImageTap: _pickProfileImage,
                    isUpdating: _isUpdating,
                  ),
                  const SizedBox(height: 60),
                  ProfileInfo(
                    name: me?.name ?? '',
                    email: me?.email ?? '',
                  ),
                  const SizedBox(height: 30),
                  ProfileMenu(
                    onLogoutTap: _showLogoutDialog,
                  ),
                ],
              ),
            ),
            loading: () => const LoadingIndicator(),
            error: (err, stack) => ErrorDisplay(
              message: 'Nie udało się załadować profilu',
              onRetry: () => ref.invalidate(meProvider),
            ),
          ),
          if (_isUpdating)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    LogoutDialog.show(context, _logout);
  }
}
