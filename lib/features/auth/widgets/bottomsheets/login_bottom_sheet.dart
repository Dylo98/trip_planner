import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_planner/core/theme/colors.dart';
import 'package:trip_planner/features/auth/controller/auth_provider.dart';
import 'package:trip_planner/features/auth/services/auth_service.dart';
import 'package:trip_planner/core/theme/text_style.dart';
import 'package:trip_planner/core/theme/input_style.dart';
import 'package:trip_planner/core/utils/validators.dart';
import 'package:trip_planner/core/widgets/buttons/form_auth_btn.dart';
import 'package:trip_planner/features/auth/widgets/bottomsheets/signup_bottom_sheet_trigger.dart';

class LoginBottomSheet extends ConsumerStatefulWidget {
  const LoginBottomSheet(this.mainContext, {super.key});

  final BuildContext mainContext;

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

    final navigator = Navigator.of(context);

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

      if (mounted) {
        navigator.pop();
      }
    } on AuthException catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = error.message;
      });
    } on Exception {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Wystąpił nieoczekiwany błąd';
      });
    }
  }

  void _navigateToSignup() {
    Navigator.of(context).pop();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showSignupBottomSheet(context);
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
          child: Text('Zaloguj się', style: AppTextStyles.heading1),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 15, left: 15, bottom: 5),
          child: Text(
            'Uzyskaj dostęp do swoich podróży i planów.',
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
                  const TextSpan(text: 'Nie masz konta? '),
                  TextSpan(
                    text: 'Zarejestruj się',
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
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.red),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              color: AppColors.red, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: AppColors.red,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  TextFormField(
                    controller: _emailController,
                    decoration: AppInputStyle.underlineInputDecoration(
                      labelText: 'E-mail',
                      hintText: 'jan.kowalski@mail.com',
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
                      labelText: 'Hasło',
                      hintText: '••••••••',
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
                      onPressed: _isLoading
                          ? null
                          : () {
                              // TODO: reset hasła
                            },
                      child: Text(
                        'Nie pamiętasz hasła?',
                        style: AppTextStyles.bodyText.copyWith(
                          color: AppColors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FormAuthBtn(
                    onPressed: _submit,
                    text: 'Zaloguj się',
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
