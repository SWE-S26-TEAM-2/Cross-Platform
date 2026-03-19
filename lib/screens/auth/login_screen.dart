import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_dimensions.dart';
import '../../constants/app_text_styles.dart';
import '../../services/mock_auth_service.dart';
import '../../widgets/social_buttons.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final MockAuthService authService = MockAuthService();

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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        borderSide: const BorderSide(color: Colors.red),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceMedium,
        vertical: AppDimensions.spaceMedium,
      ),
    );
  }

  bool isValidEmail(String email) {
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return regex.hasMatch(email);
  }

  void handleLogin() {
    if (_formKey.currentState!.validate()) {
      final email = emailController.text.trim();
      final password = passwordController.text;

      final success = authService.login(email, password);

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid email or password')),
        );
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Login successful')));

      Navigator.pushNamed(context, '/root');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Log in')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.spaceMedium),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Welcome back', style: AppTextStyles.heading1),
                const SizedBox(height: AppDimensions.spaceSmall),
                const Text(
                  'Log in to continue listening and connecting.',
                  style: AppTextStyles.artistName,
                ),
                const SizedBox(height: AppDimensions.spaceLarge),
                const SocialButtons(),

                const SizedBox(height: AppDimensions.spaceMedium),

                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('or'),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),

                const SizedBox(height: AppDimensions.spaceMedium),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: AppTextStyles.trackTitle,
                  decoration: buildInputDecoration('Email address'),
                  validator: (value) {
                    final email = value?.trim() ?? '';

                    if (email.isEmpty) {
                      return 'Email is required';
                    }
                    if (!isValidEmail(email)) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.spaceMedium),

                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  style: AppTextStyles.trackTitle,
                  decoration: buildInputDecoration('Password'),
                  validator: (value) {
                    final password = value ?? '';

                    if (password.isEmpty) {
                      return 'Password is required';
                    }
                    if (password.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    return null;
                  },
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
                    onPressed: handleLogin,
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
      ),
    );
  }
}
