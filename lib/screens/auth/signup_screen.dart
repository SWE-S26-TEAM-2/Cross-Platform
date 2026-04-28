import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_dimensions.dart';
import '../../constants/app_text_styles.dart';
import '../../main.dart' show kUseMockAuth;
import '../../providers/auth_providers.dart';
import '../../services/mock_auth_service.dart';
import '../../widgets/social_buttons.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final MockAuthService authService = MockAuthService();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool _navigatedFromProvider = false;

  @override
  void dispose() {
    emailController.dispose();
    usernameController.dispose();
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

  Future<void> handleSignup() async {
    if (!_formKey.currentState!.validate()) return;
    final email = emailController.text.trim();
    final username = usernameController.text.trim();
    final password = passwordController.text;

    if (kUseMockAuth) {
      final success = authService.signup(email, password);

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This email is already registered, login instead'),
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created successfully')),
      );

      Navigator.pushNamed(context, '/login');
      return;
    }

    await ref
        .read(authProvider.notifier)
        .register(email, password, username, '');
  }

  @override
  Widget build(BuildContext context) {
    final authState = kUseMockAuth ? null : ref.watch(authProvider);
    final isLoading = authState?.isLoading ?? false;
    final errorMessage = authState?.error;

    if (!kUseMockAuth) {
      ref.listen<AuthState>(authProvider, (prev, next) {
        if (!_navigatedFromProvider &&
            (next.successMessage ?? '').isNotEmpty) {
          _navigatedFromProvider = true;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(next.successMessage!)),
          );
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/login',
            (route) => route.settings.name == '/',
          );
        }
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Create account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.spaceMedium),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Create your account',
                  style: AppTextStyles.heading1,
                ),
                const SizedBox(height: AppDimensions.spaceSmall),
                const Text(
                  'Sign up with email address',
                  style: AppTextStyles.caption,
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
                  key: const Key('signup.email'),
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

                if (!kUseMockAuth) ...[
                  TextFormField(
                    key: const Key('signup.username'),
                    controller: usernameController,
                    style: AppTextStyles.trackTitle,
                    decoration: buildInputDecoration('Username'),
                    validator: (value) {
                      final username = value?.trim() ?? '';
                      if (username.isEmpty) {
                        return 'Username is required';
                      }
                      if (username.length < 3 || username.length > 20) {
                        return 'Username must be 3-20 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppDimensions.spaceMedium),
                ],

                TextFormField(
                  key: const Key('signup.password'),
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
                const SizedBox(height: AppDimensions.spaceMedium),

                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  style: AppTextStyles.trackTitle,
                  decoration: buildInputDecoration('Confirm password'),
                  validator: (value) {
                    final confirm = value ?? '';

                    if (confirm.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (confirm != passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.spaceLarge),

                if (errorMessage != null && errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: AppDimensions.spaceSmall,
                    ),
                    child: Text(
                      errorMessage,
                      key: const Key('signup.error'),
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    key: const Key('signup.submit'),
                    onPressed: isLoading ? null : handleSignup,
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Create account'),
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
      ),
    );
  }
}
