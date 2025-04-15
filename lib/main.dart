import 'package:flutter/material.dart';

// FIREBASE //
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

// SCREENS //
import 'package:trip_planner/features/home/screens/home.dart';
import 'package:trip_planner/features/splash/screens/splash.dart';
import 'package:trip_planner/features/auth/screens/auth.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:trip_planner/core/theme/app_theme.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SplashScreen();
            }
            if (snapshot.hasData) {
              return const HomeScreen();
            }
            return const AuthScreen();
          }),
    );
  }
}
