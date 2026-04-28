import 'package:flutter/material.dart';
import 'package:my_project/screens/auth/change_password_screen.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_dimensions.dart';
import '../../constants/app_text_styles.dart';
import '../../services/mock_auth_service.dart';
import 'change_password_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final MockAuthService authService = MockAuthService();

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
        borderRadius:
            BorderRadius.circular(AppDimensions.borderRadiusMedium),
        borderSide: BorderSide.none,
      ),
      errorBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(AppDimensions.borderRadiusMedium),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(AppDimensions.borderRadiusMedium),
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

  String? _resetError;
  String? _resetSuccess;

  void handleReset() {
    if (_formKey.currentState!.validate()) {
      final email = emailController.text.trim();

      final exists = authService.emailExists(email);

      if (!exists) {
        setState(() {
          _resetError = 'No account found with this email';
          _resetSuccess = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No account found with this email'),
          ),
        );
        return;
      }

      setState(() {
        _resetError = null;
        _resetSuccess = 'Check your email for reset instructions';
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChangePasswordScreen(email: email),),
      );
    }
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
          child: Form(
            key: _formKey,
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

                /// EMAIL FIELD
                TextFormField(
                  key: const Key('forgot.email'),
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

                if (_resetError != null) ...[
                  const SizedBox(height: AppDimensions.spaceSmall),
                  Text(
                    _resetError!,
                    key: const Key('forgot.error'),
                    style: const TextStyle(color: Colors.red),
                  ),
                ],

                if (_resetSuccess != null) ...[
                  const SizedBox(height: AppDimensions.spaceSmall),
                  Text(
                    _resetSuccess!,
                    key: const Key('forgot.success'),
                    style: const TextStyle(color: AppColors.primary),
                  ),
                ],

                const SizedBox(height: AppDimensions.spaceLarge),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    key: const Key('forgot.submit'),
                    onPressed: handleReset,
                    child: const Text('Change password'),
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
      ),
    );
  }
}