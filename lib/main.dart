import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'constants/app_theme.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'root.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/forget_password_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/auth/change_password_screen.dart';
import 'screens/library/collections_screen.dart';
import 'screens/auth/verify_email_screen.dart';

/// Compile-time flag controlling whether auth flows use the in-memory mock
/// service (default) or the real Dio-backed [AuthService] via Riverpod.
///
/// Toggle with `--dart-define=USE_MOCK_AUTH=false` when running against a
/// live backend. Defaults to `true` to keep existing mock-driven integration
/// tests passing without configuration.
const bool kUseMockAuth = bool.fromEnvironment(
  'USE_MOCK_AUTH',
  defaultValue: true,
);

void main() {
  runApp(ProviderScope(child: const SoundCloudApp()));
}

class SoundCloudApp extends StatelessWidget {
  const SoundCloudApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SoundCloud',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/signup': (context) => const SignupScreen(),
        '/login': (context) => const LoginScreen(),
        '/root': (context) => const RootScreen(),
        '/forgot_password': (context) => const ForgotPasswordScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/change_password') {
          final args = settings.arguments;
          final email = args is String ? args : '';
          return MaterialPageRoute(
            builder: (_) => ResetPasswordScreen(email: email),
            settings: settings,
          );
        }
        return null;
      },
    );
  }
}
