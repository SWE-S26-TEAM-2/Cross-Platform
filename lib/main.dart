import 'package:flutter/material.dart';
import 'constants/app_theme.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'root.dart';

void main() {
  runApp(const SoundCloudApp());
}

class SoundCloudApp extends StatelessWidget {
  const SoundCloudApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SoundCloud',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const WelcomeScreen(),
      routes: {
        '/signup': (context) => const SignupScreen(),
        '/root': (context) => const RootScreen(),
      },
    );
  }
}
