import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_dimensions.dart';
import '../../constants/app_text_styles.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spaceMedium),
          child: Column(
            children: [
              const Spacer(),

              /// Logo (temporary icon)
              // const Icon(
              //   Icons.music_note,
              //   color: AppColors.primary,
              //   size: 48,
              // ),
              const Image(
                image: AssetImage('assets/images/soundcloud_logo.png'),
                width: 120,
                height: 120,
                
              ),


              const SizedBox(height: AppDimensions.spaceLarge),

              /// Title
              const Text(
                'Where artists\n& fans connect.',
                textAlign: TextAlign.center,
                style: AppTextStyles.heading1,
              ),

              const SizedBox(height: AppDimensions.spaceExtraLarge),

              /// Create Account Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                  child: const Text('Create an account'),
                ),
              ),

              const SizedBox(height: AppDimensions.spaceMedium),

              /// Login Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: const Text('Log in'),
                ),
              ),

              const SizedBox(height: AppDimensions.spaceExtraLarge),
            ],
          ),
        ),
      ),
    );
  }
}
