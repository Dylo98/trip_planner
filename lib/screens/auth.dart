import 'package:flutter/material.dart';
import 'package:trip_planner/widgets/buttons/form_auth_btn.dart';
import 'package:trip_planner/widgets/triggers/login_bottom_sheet_trigger.dart';
import 'package:trip_planner/widgets/triggers/signup_bottom_sheet_trigger.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background_image1.jpg"),
            // colorFilter: ColorFilter.mode(
            //   Colors.black.withValues(alpha: 0.3),
            //   BlendMode.darken,
            // ),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            children: [
              Image.asset("assets/images/logo.png"),
              FormAuthBtn(
                  onPressed: () {
                    showLoginBottomSheet(context);
                  },
                  text: 'Zaloguj się'),
              const SizedBox(height: 10),
              FormAuthBtn(
                  onPressed: () {
                    showSignupBottomSheet(context);
                  },
                  text: 'Zarejestruj się'),
            ],
          ),
        ),
      ),
    );
  }
}
