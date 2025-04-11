import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// SERVICES //
import 'package:trip_planner/services/auth_service.dart';

// WIDGETS //
import 'package:trip_planner/widgets/authflashbars/error_flushbar.dart';
import 'package:trip_planner/widgets/buttons/form_auth_btn.dart';

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
    } on FirebaseAuthException catch (error) {
      var errorMessage = 'Nieudana próba zalogowania.';
      if (error.code == 'invalid-email') {
        errorMessage = 'Błędny adres e-mail';
      } else if (error.code == 'user-not-found') {
        errorMessage = 'Niepoprawne dane logowania';
      }
      if (!widget.mainContext.mounted) return;
      ErrorFlushbar.show(
        context: widget.mainContext,
        message: errorMessage,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty ||
                          !value.contains('@')) {
                        return 'Niepoprawny e-mail.';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _enteredEmail = value!;
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Hasło',
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.trim().length < 6) {
                        return 'Hasło musi zawierać minimum 6 znaków';
                      }
                      return null;
                    },
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
