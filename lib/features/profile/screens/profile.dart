import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

// PROVIDERS
import 'package:trip_planner/features/auth/controller/user_provider.dart';
import 'package:trip_planner/features/auth/controller/auth_provider.dart';

// SERVICES
import 'package:trip_planner/features/profile/services/profile_image_service.dart';

// CONSTANTS
import 'package:trip_planner/features/home/constants/layout_constants.dart';

// NOTIFICATIONS (SNACKBARS)
import 'package:trip_planner/core/widgets/app_notifications.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  final ProfileImageService _profileImageService = ProfileImageService();

  File? _selectedProfileImage;
  File? _selectedCoverImage;
  bool _isUpdating = false;

  Future<void> _pickProfileImage() async {
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

  Future<void> _uploadProfileImage(File imageFile) async {
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
        AppNotifications.showError(
          context: context,
          message: 'Nie udało się zapisać zdjęcia',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  Future<void> _uploadCoverImage(File imageFile) async {
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
        AppNotifications.showError(
          context: context,
          message: 'Nie udało się zapisać zdjęcia',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  Future<void> _logout() async {
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
  }

  @override
  Widget build(BuildContext context) {
    final meAsync = ref.watch(meProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        elevation: 0,
      ),
      body: Stack(
        children: [
          meAsync.when(
            data: (me) => SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _buildCoverImage(me?.coverImage),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _pickCoverImage,
                            borderRadius: BorderRadius.circular(25),
                            child: _buildEditButton(icon: Icons.camera_alt),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -50,
                        left: 20,
                        child: Stack(
                          children: [
                            _buildProfileImage(me?.avatar),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _pickProfileImage,
                                  borderRadius: BorderRadius.circular(20),
                                  child: _buildEditButton(
                                    icon: Icons.camera_alt,
                                    size: 40,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 60),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          me?.name ?? 'Brak nazwy',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          me?.email ?? '',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Divider(),
                  _buildProfileOption(
                    icon: Icons.person_outline,
                    title: 'Edytuj profil',
                    onTap: () => context.push('/edit-profile'),
                  ),
                  _buildProfileOption(
                    icon: Icons.notifications_outlined,
                    title: 'Powiadomienia',
                    onTap: () => context.push('/notification-settings'),
                  ),
                  _buildProfileOption(
                    icon: Icons.security_outlined,
                    title: 'Prywatność i bezpieczeństwo',
                    onTap: () => context.push('/change-password'),
                  ),
                  const Divider(height: 30),
                  _buildProfileOption(
                    icon: Icons.logout,
                    title: 'Wyloguj się',
                    textColor: Colors.red,
                    onTap: _showLogoutDialog,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Nie udało się załadować profilu'),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => ref.invalidate(meProvider),
                    child: const Text('Spróbuj ponownie'),
                  ),
                ],
              ),
            ),
          ),
          if (_isUpdating)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCoverImage(String? coverImageUrl) {
    return GestureDetector(
      onTap: _pickCoverImage,
      child: Container(
        height: coverHeight,
        width: double.infinity,
        color: Colors.black,
        child: _selectedCoverImage != null
            ? Image.file(_selectedCoverImage!, fit: BoxFit.cover)
            : (coverImageUrl?.isNotEmpty == true
                ? Image.network(
                    coverImageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Image.asset(
                      'assets/images/image_home.jpg',
                      fit: BoxFit.cover,
                    ),
                  )
                : Image.asset(
                    'assets/images/image_home.jpg',
                    fit: BoxFit.cover,
                  )),
      ),
    );
  }

  Widget _buildProfileImage(String? avatarUrl) {
    final hasAvatar =
        avatarUrl?.isNotEmpty == true || _selectedProfileImage != null;

    return GestureDetector(
      onTap: _pickProfileImage,
      child: CircleAvatar(
        radius: profileHeight / 2,
        backgroundColor: Colors.white,
        child: CircleAvatar(
          radius: profileHeight / 2 - 5,
          backgroundColor: Colors.grey.shade300,
          backgroundImage: _selectedProfileImage != null
              ? FileImage(_selectedProfileImage!)
              : (hasAvatar ? NetworkImage(avatarUrl!) : null) as ImageProvider?,
          child: !hasAvatar
              ? const Icon(Icons.person, size: 50, color: Colors.white70)
              : null,
        ),
      ),
    );
  }

  Widget _buildEditButton({
    required IconData icon,
    double size = 45,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        icon,
        size: size * 0.5,
        color: Colors.grey[700],
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor),
      title: Text(
        title,
        style: TextStyle(fontSize: 16, color: textColor),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Wyloguj się'),
        content: const Text('Czy na pewno chcesz się wylogować?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Anuluj'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            child: const Text('Wyloguj', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
