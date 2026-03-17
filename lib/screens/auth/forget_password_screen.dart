import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_dimensions.dart';
import '../../constants/app_text_styles.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
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
        title: const Text('Forgot password'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.spaceMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Reset your password',
                style: AppTextStyles.heading1,
              ),
              const SizedBox(height: AppDimensions.spaceSmall),
              const Text(
                'Enter your email address and we will send you instructions to reset your password.',
                style: AppTextStyles.artistName,
              ),
              const SizedBox(height: AppDimensions.spaceLarge),

              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                style: AppTextStyles.trackTitle,
                decoration: buildInputDecoration('Email address'),
              ),

              const SizedBox(height: AppDimensions.spaceLarge),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Password reset link sent'),
                      ),
                    );
                  },
                  child: const Text('Send reset link'),
                ),
              ),

              const SizedBox(height: AppDimensions.spaceMedium),

              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Back to log in',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}