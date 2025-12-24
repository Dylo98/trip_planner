import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/core/theme/button_style.dart';
import 'package:trip_planner/core/theme/colors.dart';
import 'package:trip_planner/features/auth/constants/auth_messages.dart';
import 'package:trip_planner/features/auth/providers/auth_provider.dart';
import 'package:trip_planner/features/auth/services/auth_service.dart';
import 'package:trip_planner/core/theme/text_style.dart';
import 'package:trip_planner/core/theme/input_style.dart';
import 'package:trip_planner/core/utils/validators.dart';
import 'package:trip_planner/core/widgets/app_notifications.dart';
import 'package:trip_planner/core/widgets/buttons/form_auth_btn.dart';
import 'package:trip_planner/features/auth/widgets/auth_error_message.dart';
import 'package:trip_planner/features/auth/widgets/bottomsheets/auth_bottom_sheet_wrapper.dart';
import 'package:trip_planner/features/auth/widgets/bottomsheets/signup_bottom_sheet.dart';

class LoginBottomSheet extends ConsumerStatefulWidget {
  const LoginBottomSheet({super.key});

  @override
  ConsumerState<LoginBottomSheet> createState() => _LoginBottomSheetState();
}

class _LoginBottomSheetState extends ConsumerState<LoginBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authService = ref.read(authProvider);

    try {
      await authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } on AuthException catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = error.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = AuthMessages.unexpectedError;
      });
    }
  }

  void _navigateToSignup() {
    Navigator.of(context).pop();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      AuthBottomSheetWrapper.show(
        context: context,
        child: const SignupBottomSheet(),
      );
    });
  }

  Future<void> _showForgotPasswordDialog() async {
    final emailController = TextEditingController(
      text: _emailController.text.trim(),
    );

    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16),
        title: const Row(
          children: [
            Icon(
              Icons.lock_reset,
              color: AppColors.limeSliceDark,
            ),
            SizedBox(width: 8),
            Text(
              'Reset hasła',
              style: AppTextStyles.heading3,
            ),
          ],
        ),
        content: SizedBox(
          width: MediaQuery.of(ctx).size.width * 0.9,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Podaj adres e-mail, na który wyślemy link do resetu hasła.',
                  style: AppTextStyles.bodyTextSecondary,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailController,
                  decoration: AppInputStyle.inputDecoration(
                    icon: Icons.email,
                    labelText: 'E-mail',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: Validators.validateEmail,
                  autofocus: true,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Anuluj',
              style: AppTextStyles.bodySmallRed,
            ),
          ),
          GradientButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx, true);
              }
            },
            icon: const Icon(Icons.send, color: AppColors.darkGrey),
            child: const Text(
              'Wyślij',
              style: AppTextStyles.buttonText,
            ),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      try {
        await ref.read(authProvider).resetPassword(emailController.text.trim());
        if (mounted) {
          AppNotifications.showSuccess(
            context: context,
            message: 'Link do resetu hasła został wysłany',
          );
          setState(() => _errorMessage = null);
        }
      } on AuthException catch (e) {
        if (mounted) {
          AppNotifications.showError(
            context: context,
            message: e.message,
          );
        }
      }
    }

    emailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 15, left: 15, bottom: 5),
          child: Text(AuthMessages.loginTitle, style: AppTextStyles.heading1),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 15, left: 15, bottom: 5),
          child: Text(
            AuthMessages.loginSubtitle,
            style: AppTextStyles.bodyText,
          ),
        ),
        Padding(
          padding:
              const EdgeInsets.only(left: 15, right: 15, top: 4, bottom: 8),
          child: InkWell(
            onTap: _navigateToSignup,
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.bodyText,
                children: [
                  const TextSpan(text: AuthMessages.noAccount),
                  TextSpan(
                    text: AuthMessages.signupLink,
                    style: AppTextStyles.bodyText.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.all(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  if (_errorMessage != null)
                    AuthErrorMessage(message: _errorMessage!),
                  TextFormField(
                    controller: _emailController,
                    decoration: AppInputStyle.underlineInputDecoration(
                      labelText: AuthMessages.emailLabel,
                      hintText: AuthMessages.emailHint,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    textCapitalization: TextCapitalization.none,
                    validator: Validators.validateEmail,
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordController,
                    decoration: AppInputStyle.underlineInputDecoration(
                      labelText: AuthMessages.passwordLabel,
                      hintText: AuthMessages.passwordHint,
                    ).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppColors.grey,
                        ),
                        onPressed: _isLoading
                            ? null
                            : () {
                                setState(
                                    () => _obscurePassword = !_obscurePassword);
                              },
                      ),
                    ),
                    obscureText: _obscurePassword,
                    validator: Validators.validatePassword,
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _isLoading ? null : _showForgotPasswordDialog,
                      child: Text(
                        AuthMessages.forgotPassword,
                        style: AppTextStyles.bodyText
                            .copyWith(color: AppColors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FormAuthBtn(
                    onPressed: _submit,
                    text: AuthMessages.loginButton,
                    isLoading: _isLoading,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
