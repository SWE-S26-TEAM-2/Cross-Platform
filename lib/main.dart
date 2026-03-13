import 'package:flutter/material.dart';
import 'constants/app_theme.dart'; //The soundcloud's theme
import 'screens/home/home_screen.dart'; //Home screen
import 'screens/auth/welcome_screen.dart'; //Welcome screen for auth flow

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
      theme: AppTheme.darkTheme, //Take the styling from the app_theme.dart file
      // home: const HomeScreen(), commented out for now, will be replaced by welcome screen
      home: const WelcomeScreen(), // Temporary welcome screen for auth flow
    );
  }
}
