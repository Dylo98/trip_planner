import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:trip_planner/core/widgets/buttons/form_auth_btn.dart';
import 'package:trip_planner/features/auth/constants/auth_messages.dart';
import 'package:trip_planner/features/auth/widgets/bottomsheets/auth_bottom_sheet_wrapper.dart';
import 'package:trip_planner/features/auth/widgets/bottomsheets/login_bottom_sheet.dart';
import 'package:trip_planner/features/auth/widgets/bottomsheets/signup_bottom_sheet.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/images/background_image1.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 1.5,
              sigmaY: 1.5,
            ),
            child: Container(
              color: Colors.black.withValues(alpha: 0.2),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("assets/images/logo.png"),
                const SizedBox(height: 40),
                FormAuthBtn(
                  onPressed: () {
                    AuthBottomSheetWrapper.show(
                      context: context,
                      child: const LoginBottomSheet(),
                    );
                  },
                  text: AuthMessages.loginButton,
                ),
                const SizedBox(height: 10),
                FormAuthBtn(
                  onPressed: () {
                    AuthBottomSheetWrapper.show(
                      context: context,
                      child: const SignupBottomSheet(),
                    );
                  },
                  text: AuthMessages.signupButton,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
