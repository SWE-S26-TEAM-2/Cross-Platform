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
                  IconButton(
                    icon: const Icon(Icons.settings_outlined),
                   onPressed: () {},
                  ),
                ],
              ),
         
            ),
         ],
      )
    );
  }
}