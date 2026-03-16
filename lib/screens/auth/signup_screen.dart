import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_dimensions.dart';
import '../../constants/app_text_styles.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  InputDecoration buildInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: AppTextStyles.caption,
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
      appBar: AppBar(title: const Text('Create account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.spaceMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Create your account', style: AppTextStyles.heading1),
              const SizedBox(height: AppDimensions.spaceSmall),
              const Text(
                'Sign up with email address',
                style: AppTextStyles.caption,
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
              const SizedBox(height: AppDimensions.spaceMedium),

              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                style: AppTextStyles.trackTitle,
                decoration: buildInputDecoration('Confirm password'),
              ),
              const SizedBox(height: AppDimensions.spaceLarge),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // temporary action for now
                    Navigator.pushNamed(context, '/home');
                  },
                  child: const Text('Create account'),
                ),
              ),

              const SizedBox(height: AppDimensions.spaceMedium),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account? ',
                    style: AppTextStyles.caption,
                  ),
                  GestureDetector(
                    onTap: () {
                      /// Not yet created
                      Navigator.pushNamed(context, '/login');
                    },
                    child: const Text(
                      'Log in',
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
