import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_dimensions.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/auth_providers.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String? email;

  const ResetPasswordScreen({super.key, this.email});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController tokenController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    tokenController.dispose();
    newPasswordController.dispose();
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

  bool hasUppercase(String value) {
    return RegExp(r'[A-Z]').hasMatch(value);
  }

  bool hasNumber(String value) {
    return RegExp(r'\d').hasMatch(value);
  }

  String extractBackendMessage(String error) {
    final lower = error.toLowerCase();

    if (lower.contains('410')) {
      return 'Reset token expired. Please request a new reset email.';
    }
    if (lower.contains('400')) {
      return 'Invalid token or password does not meet requirements.';
    }

    return error;
  }

  Future<void> handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    await ref
        .read(authProvider.notifier)
        .resetPassword(
          tokenController.text.trim(),
          newPasswordController.text.trim(),
        );

    final authState = ref.read(authProvider);

    if (!mounted) return;

    if (authState.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(extractBackendMessage(authState.error!))),
      );
      return;
    }

    if (authState.successMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(authState.successMessage!)));

      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Reset password')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.spaceMedium),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Set a new password', style: AppTextStyles.heading1),
                const SizedBox(height: AppDimensions.spaceSmall),
                Text(
                  widget.email == null
                      ? 'Enter the reset token from your email and choose a new password.'
                      : 'Enter the reset token sent to ${widget.email} and choose a new password.',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: AppDimensions.spaceLarge),

                TextFormField(
                  controller: tokenController,
                  style: AppTextStyles.trackTitle,
                  decoration: buildInputDecoration('Reset token'),
                  validator: (value) {
                    final token = value?.trim() ?? '';
                    if (token.isEmpty) {
                      return 'Reset token is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.spaceMedium),

                TextFormField(
                  controller: newPasswordController,
                  obscureText: true,
                  style: AppTextStyles.trackTitle,
                  decoration: buildInputDecoration('New password'),
                  validator: (value) {
                    final password = value?.trim() ?? '';

                    if (password.isEmpty) {
                      return 'New password is required';
                    }
                    if (password.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    if (!hasUppercase(password)) {
                      return 'Password must contain at least 1 uppercase letter';
                    }
                    if (!hasNumber(password)) {
                      return 'Password must contain at least 1 number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.spaceMedium),

                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  style: AppTextStyles.trackTitle,
                  decoration: buildInputDecoration('Confirm new password'),
                  validator: (value) {
                    final confirm = value?.trim() ?? '';

                    if (confirm.isEmpty) {
                      return 'Please confirm your new password';
                    }
                    if (confirm != newPasswordController.text.trim()) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppDimensions.spaceLarge),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: authState.isLoading ? null : handleResetPassword,
                    child: authState.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Reset password'),
                  ),
                ),

                const SizedBox(height: AppDimensions.spaceMedium),

                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/login',
                        (route) => false,
                      );
                    },
                    child: const Text(
                      'Back to login',
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
