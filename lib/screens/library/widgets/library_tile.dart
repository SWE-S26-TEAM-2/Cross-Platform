import 'package:flutter/material.dart';
import 'package:my_project/mock_data/mock_tracks.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_dimensions.dart';
import '../../../constants/app_text_styles.dart';
import 'package:my_project/screens/home/more_like_section.dart';

class LibraryTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const LibraryTile({super.key, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.spaceMedium,
          horizontal: AppDimensions.spaceMedium,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Tile title
            Text(title, style: AppTextStyles.trackTitle),

            // Arrow icon
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
