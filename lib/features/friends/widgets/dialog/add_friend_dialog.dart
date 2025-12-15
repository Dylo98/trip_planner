import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/core/theme/button_style.dart';
import 'package:trip_planner/core/theme/colors.dart';
import 'package:trip_planner/core/theme/input_style.dart';
import 'package:trip_planner/core/theme/text_style.dart';
import 'package:trip_planner/core/utils/action_lock.dart';
import 'package:trip_planner/core/utils/validators.dart';
import 'package:trip_planner/core/widgets/app_notifications.dart';
import 'package:trip_planner/features/friends/providers/friends_provider.dart';

class AddFriendDialog extends ConsumerStatefulWidget {
  const AddFriendDialog({super.key});

  @override
  ConsumerState<AddFriendDialog> createState() => _AddFriendDialogState();
}

class _AddFriendDialogState extends ConsumerState<AddFriendDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _actionLock = ActionLock();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendRequest() async {
    if (!_formKey.currentState!.validate()) return;

    await _actionLock.run(() async {
      setState(() => _isLoading = true);

      try {
        await ref
            .read(friendServiceProvider)
            .sendFriendRequest(_emailController.text.trim());

        if (mounted) {
          Navigator.pop(context);
          AppNotifications.showSuccess(
            context: context,
            message: 'Wysłano zaproszenie do znajomych',
          );
        }
      } catch (e) {
        if (mounted) {
          AppNotifications.showError(
            context: context,
            message: e.toString().replaceFirst('Exception: ', ''),
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
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: const Row(
        children: [
          Icon(
            Icons.person_add,
            color: AppColors.limeSliceDark,
          ),
          SizedBox(width: 8),
          Text(
            'Dodaj znajomego',
            style: AppTextStyles.heading3,
          ),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Podaj adres e-mail znajomego, którego chcesz dodać.',
                style: AppTextStyles.bodyTextSecondary,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: AppInputStyle.inputDecoration(
                  icon: Icons.email,
                  labelText: 'E-mail',
                ),
                keyboardType: TextInputType.emailAddress,
                validator: Validators.validateEmail,
                enabled: !_isLoading,
                autofocus: true,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text(
            'Anuluj',
            style: AppTextStyles.bodySmallRed,
          ),
        ),
        GradientButton(
          onPressed: _isLoading ? null : _sendRequest,
          icon: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    color: AppColors.darkGrey,
                    strokeWidth: 2,
                  ),
                )
              : const Icon(Icons.send, color: AppColors.darkGrey),
          child: const Text(
            'Wyślij zaproszenie',
            style: AppTextStyles.buttonText,
          ),
        )
      ],
    );
  }
}
