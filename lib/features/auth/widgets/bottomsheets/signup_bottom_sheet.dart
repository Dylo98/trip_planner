import 'package:flutter/material.dart';

// SERVICES IMPORT //
import 'package:trip_planner/data/services/auth_service.dart';

// UTILS //
import 'package:trip_planner/core/utils/validators.dart';

// WIDGETS IMPORT //
import 'package:trip_planner/features/auth/widgets/authflashbars/success_flushbar.dart';
import 'package:trip_planner/features/auth/widgets/authflashbars/error_flushbar.dart';
import 'package:trip_planner/core/widgets/buttons/form_auth_btn.dart';

final _authService = AuthService();

class SignupBottomSheet extends StatefulWidget {
  const SignupBottomSheet(this.mainContext, {super.key});

  final BuildContext mainContext;

  @override
  State<SignupBottomSheet> createState() => _SignupBottomSheetState();
}

class _SignupBottomSheetState extends State<SignupBottomSheet> {
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
      await _authService.signup(
        email: _enteredEmail,
        password: _enteredPassword,
      );
      if (!widget.mainContext.mounted) return;
      Navigator.of(widget.mainContext).pop();
      SuccessFlushbar.show(
        context: widget.mainContext,
        message: 'Utworzono konto!',
      );
      // showLoginBottomSheet(widget.mainContext);
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
      children: [
        Container(
          decoration: BoxDecoration(),
          child: Card(
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
                    FormAuthBtn(onPressed: _submit, text: 'Zarejestruj się'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
