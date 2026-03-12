import 'package:flutter/material.dart';
import 'constants/app_theme.dart'; //The soundcloud's theme
import 'screens/home/home_screen.dart'; //Home screen

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
      home: const HomeScreen(),
    );
  }
}
