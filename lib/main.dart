import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'constants/app_theme.dart';
import 'root.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/forget_password_screen.dart';
import 'screens/subscription/stripe_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initStripe();

  runApp(const ProviderScope(child: SoundCloudApp()));
}

class SoundCloudApp extends StatelessWidget {
  const SoundCloudApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SoundCloud',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const RootScreen(),
      routes: {
        '/signup': (context) => const SignupScreen(),
        '/login': (context) => const LoginScreen(),
        '/root': (context) => const RootScreen(),
        '/forgot_password': (context) => const ForgotPasswordScreen(),
      },
    );
  }
}
