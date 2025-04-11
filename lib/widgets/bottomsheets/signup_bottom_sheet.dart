import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// SERVICES IMPORT //
import 'package:trip_planner/services/auth_service.dart';

// WIDGETS IMPORT //
import 'package:trip_planner/widgets/authflashbars/error_flushbar.dart';
import 'package:trip_planner/widgets/authflashbars/success_flushbar.dart';
import 'package:trip_planner/widgets/buttons/form_auth_btn.dart';

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
    } on FirebaseAuthException catch (error) {
      var errorMessage = 'Wystąpił błąd podczas rejestracji.';
      if (error.code == 'email-already-in-use') {
        errorMessage = 'Adres e-mail jest już zajęty.';
      } else if (error.code == 'invalid-email') {
        errorMessage = 'Adres e-mail jest nie poprawny.';
      } else if (error.code == 'weak-password') {
        errorMessage = 'Hasło jest zbyt słabe';
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
