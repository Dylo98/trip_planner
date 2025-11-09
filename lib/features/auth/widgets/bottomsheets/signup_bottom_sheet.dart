import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/core/theme/colors.dart';
import 'package:trip_planner/features/auth/constants/auth_messages.dart';
import 'package:trip_planner/features/auth/controller/auth_provider.dart';
import 'package:trip_planner/features/auth/services/auth_service.dart';
import 'package:trip_planner/core/utils/validators.dart';
import 'package:trip_planner/core/theme/text_style.dart';
import 'package:trip_planner/core/theme/input_style.dart';
import 'package:trip_planner/core/widgets/buttons/form_auth_btn.dart';
import 'package:trip_planner/features/auth/widgets/auth_error_message.dart';
import 'package:trip_planner/features/auth/widgets/bottomsheets/auth_bottom_sheet_wrapper.dart';
import 'package:trip_planner/features/auth/widgets/bottomsheets/login_bottom_sheet.dart';

class SignupBottomSheet extends ConsumerStatefulWidget {
  const SignupBottomSheet({super.key});

  @override
  ConsumerState<SignupBottomSheet> createState() => _SignupBottomSheetState();
}

class _SignupBottomSheetState extends ConsumerState<SignupBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
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
      await authService.signup(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
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
        _errorMessage = '${AuthMessages.unexpectedError}: ${e.toString()}';
      });
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pop();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      AuthBottomSheetWrapper.show(
        context: context,
        child: const LoginBottomSheet(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 15, left: 15, bottom: 5),
          child: Text(AuthMessages.signupTitle, style: AppTextStyles.heading1),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 15, left: 15, bottom: 5),
          child: InkWell(
            onTap: _navigateToLogin,
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.bodyText,
                children: [
                  const TextSpan(text: AuthMessages.hasAccount),
                  TextSpan(
                    text: AuthMessages.loginLink,
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
                    controller: _nameController,
                    decoration: AppInputStyle.underlineInputDecoration(
                      labelText: AuthMessages.nameLabel,
                      hintText: AuthMessages.nameHint,
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: Validators.validateName,
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 8),
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
                  const SizedBox(height: 20),
                  FormAuthBtn(
                    onPressed: _submit,
                    text: AuthMessages.signupButton,
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
