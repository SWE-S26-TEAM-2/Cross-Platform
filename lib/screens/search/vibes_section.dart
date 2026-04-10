import 'package:flutter/material.dart';
import 'package:my_project/constants/app_dimensions.dart';
import 'package:my_project/constants/app_text_styles.dart';

class VibesSection extends StatelessWidget {
  const VibesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(
        horizontal: AppDimensions.spaceLarge,
        vertical: AppDimensions.spaceExtraLarge
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vibes',
            style: AppTextStyles.heading1,
          )
        ],
      ),
    );
  }
}