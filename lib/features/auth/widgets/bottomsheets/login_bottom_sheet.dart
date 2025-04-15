import 'package:flutter/material.dart';

// SERVICES //
import 'package:trip_planner/data/services/auth_service.dart';

// THEME //
import 'package:trip_planner/core/theme/text_style.dart';

// UTILS //
import 'package:trip_planner/core/utils/validators.dart';

// WIDGETS //
import 'package:trip_planner/features/auth/widgets/authflashbars/error_flushbar.dart';
import 'package:trip_planner/core/widgets/buttons/form_auth_btn.dart';

final _authService = AuthService();

class LoginBottomSheet extends StatefulWidget {
  const LoginBottomSheet(this.mainContext, {super.key});

  final BuildContext mainContext;

  @override
  State<LoginBottomSheet> createState() => _LoginBottomSheetState();
}

class _LoginBottomSheetState extends State<LoginBottomSheet> {
  final _form = GlobalKey<FormState>();

  var _enteredEmail = '';
  var _enteredPassword = '';

  void _submit() async {
    final isValid = _form.currentState!.validate();

    if (!isValid) {
      return;
    }
    _form.currentState!.save();
    try {
      await _authService.login(
        email: _enteredEmail,
        password: _enteredPassword,
      );
      if (widget.mainContext.mounted) {
        Navigator.of(widget.mainContext).pop();
      }
    } on AuthException catch (error) {
      if (!widget.mainContext.mounted) return;
      ErrorFlushbar.show(
        context: widget.mainContext,
        message: error.message,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 15, left: 15, bottom: 5),
          child: Text(
            'Login',
            style: AppTextStyles.heading1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 5, left: 15, bottom: 5),
          child: Text(
            'Wtiaj ponownie',
            style: AppTextStyles.bodyText,
          ),
        ),
        Card(
          margin: const EdgeInsets.all(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _form,
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'E-mail',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    textCapitalization: TextCapitalization.none,
                    validator: Validators.validateEmail,
                    onSaved: (value) {
                      _enteredEmail = value!;
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Hasło',
                    ),
                    obscureText: true,
                    validator: Validators.validatePassword,
                    onSaved: (value) {
                      _enteredPassword = value!;
                    },
                  ),
                  const SizedBox(height: 12),
                  FormAuthBtn(onPressed: _submit, text: 'Zaloguj się'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
