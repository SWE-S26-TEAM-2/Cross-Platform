import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_dimensions.dart';
import '../../constants/app_text_styles.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  InputDecoration buildInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: AppTextStyles.artistName,
      filled: true,
      fillColor: AppColors.surfaceLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceMedium,
        vertical: AppDimensions.spaceMedium,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Log in'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.spaceMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome back',
                style: AppTextStyles.heading1,
              ),
              const SizedBox(height: AppDimensions.spaceSmall),
              const Text(
                'Log in to continue listening and connecting.',
                style: AppTextStyles.artistName,
              ),
              const SizedBox(height: AppDimensions.spaceLarge),

              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                style: AppTextStyles.trackTitle,
                decoration: buildInputDecoration('Email address'),
              ),
              const SizedBox(height: AppDimensions.spaceMedium),

              TextField(
                controller: passwordController,
                obscureText: true,
                style: AppTextStyles.trackTitle,
                decoration: buildInputDecoration('Password'),
              ),
              const SizedBox(height: AppDimensions.spaceSmall),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/forgot_password');
                  },
                  child: const Text(
                    'Forgot password?',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.spaceMedium),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/root');
                  },
                  child: const Text('Log in'),
                ),
              ),

              const SizedBox(height: AppDimensions.spaceMedium),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account? ",
                    style: AppTextStyles.artistName,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/signup');
                    },
                    child: const Text(
                      'Create account',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}