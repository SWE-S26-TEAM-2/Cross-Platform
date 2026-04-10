import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_dimensions.dart';
import '../../constants/app_text_styles.dart';
import '../../services/mock_auth_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  final String email;

  const ChangePasswordScreen({super.key, required this.email});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final MockAuthService authService = MockAuthService();

  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
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

  void handleChangePassword() {
    if (_formKey.currentState!.validate()) {
      final newPassword = newPasswordController.text;

      final success = authService.changePassword(widget.email, newPassword);

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update password')),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password changed successfully')),
      );

      Navigator.pushNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Change password')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.spaceMedium),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Create a new password',
                  style: AppTextStyles.heading1,
                ),
                const SizedBox(height: AppDimensions.spaceSmall),
                Text(
                  'Change password for ${widget.email}',
                  style: AppTextStyles.artistName,
                ),
                const SizedBox(height: AppDimensions.spaceLarge),

                TextFormField(
                  controller: newPasswordController,
                  obscureText: true,
                  style: AppTextStyles.trackTitle,
                  decoration: buildInputDecoration('New password'),
                  validator: (value) {
                    final newPassword = value ?? '';

                    if (newPassword.isEmpty) {
                      return 'New password is required';
                    }

                    if (newPassword.length < 8) {
                      return 'Password must be at least 8 characters';
                    }

                    final oldPassword = authService.getUserPassword(
                      widget.email,
                    );

                    if (oldPassword != null && newPassword == oldPassword) {
                      return 'New password must be different from old password';
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
                    final confirmPassword = value ?? '';

                    if (confirmPassword.isEmpty) {
                      return 'Please confirm your new password';
                    }
                    if (confirmPassword != newPasswordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppDimensions.spaceLarge),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: handleChangePassword,
                    child: const Text('Change password'),
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
