import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_dimensions.dart';
import '../../constants/app_text_styles.dart';
 
class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

   @override
   Widget build(BuildContext context){
     return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
         backgroundColor: AppColors.background,
         elevation: 0,
         title: const Text(
          'Library',
          style: AppTextStyles.heading2,
          ),
         actions: [
           Padding(
            padding: const EdgeInsets.only(
              right: AppDimensions.spaceMedium,
            ),

            child: Row(
              children: [
                IconButton(
                    icon: const Icon(Icons.settings_outlined),
                   onPressed: () {},
                  ), 
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: AppDimensions.avatarSizeSmall,
                    height: AppDimensions.avatarSizeSmall,
                    decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surfaceLight,
                    ),
                  )
                ),
                  const SizedBox(width: AppDimensions.spaceSmall),
                  
                ],
              ),
         
            ),
         ],
        ),
      body:  ListView(
        padding: EdgeInsets.all(AppDimensions.spaceMedium),
       
          children:[
            LibraryTile(title: 'Liked Tracks', onTap:() {}),
            const SizedBox(height: AppDimensions.spaceSmall),
            LibraryTile(title: 'Playlists', onTap:() {}),
            const SizedBox(height: AppDimensions.spaceSmall),
            LibraryTile(title: 'Albums', onTap:() {}),
            const SizedBox(height: AppDimensions.spaceSmall),
            LibraryTile(title: 'Following', onTap:() {}),
            const SizedBox(height: AppDimensions.spaceSmall),
            LibraryTile(title: 'Stations', onTap:() {}),
            const SizedBox(height: AppDimensions.spaceSmall),
            LibraryTile(title: 'Your insights', onTap:() {}),
            const SizedBox(height: AppDimensions.spaceSmall),
            LibraryTile(title: 'Your uploads', onTap:() {}),
            const SizedBox(height: AppDimensions.spaceSmall),
          ],

        ),
      );
        
        
    
  }
}

class LibraryTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const LibraryTile({
    super.key, 
    required this.title,
    required this.onTap,
  });

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
            Text(
              title,
              style: AppTextStyles.trackTitle,
            ),

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
 
