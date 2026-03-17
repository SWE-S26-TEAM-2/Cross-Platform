import 'package:flutter/material.dart';
import 'package:my_project/constants/app_colors.dart';
import 'package:my_project/constants/app_dimensions.dart';
import 'package:my_project/constants/app_text_styles.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({
    super.key,
    required this.onTabSelected,
  }); // ← added onTabSelected
  final Function(int) onTabSelected; // ← added

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return _BottomNavBarView(
      selectedIndex: _selectedIndex,
      onTap: (index) => setState(() {
        _selectedIndex = index;
        widget.onTabSelected(index); // ← replaced switch with this
      }),
    );
  }
}

class _BottomNavBarView extends StatelessWidget {
  const _BottomNavBarView({required this.selectedIndex, required this.onTap});

  final int selectedIndex;
  final Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceMedium,
      ),
      height: AppDimensions.bottomNavBarHeight,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.background,
        shape: BoxShape.rectangle,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          /// Home
          GestureDetector(
            onTap: () => onTap(0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  selectedIndex == 0 ? Icons.home : Icons.home_outlined,
                  size: 30,
                  color: selectedIndex == 0
                      ? AppColors.textPrimary
                      : AppColors.textMuted,
                ),
                const SizedBox(height: AppDimensions.spaceExtraSmall),
                Text(
                  'Home',
                  style: AppTextStyles.caption.copyWith(
                    color: selectedIndex == 0
                        ? AppColors.textPrimary
                        : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),

          /// Feed
          GestureDetector(
            onTap: () => onTap(1),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  selectedIndex == 1
                      ? Icons.subscriptions
                      : Icons.subscriptions_outlined,
                  size: 30,
                  color: selectedIndex == 1
                      ? AppColors.textPrimary
                      : AppColors.textMuted,
                ),
                const SizedBox(height: AppDimensions.spaceExtraSmall),
                Text(
                  'Feed',
                  style: AppTextStyles.caption.copyWith(
                    color: selectedIndex == 1
                        ? AppColors.textPrimary
                        : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),

          /// Search
          GestureDetector(
            onTap: () => onTap(2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  selectedIndex == 2 ? Icons.search : Icons.search_outlined,
                  size: 30,
                  color: selectedIndex == 2
                      ? AppColors.textPrimary
                      : AppColors.textMuted,
                ),
                const SizedBox(height: AppDimensions.spaceExtraSmall),
                Text(
                  'Search',
                  style: AppTextStyles.caption.copyWith(
                    color: selectedIndex == 2
                        ? AppColors.textPrimary
                        : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),

          /// Library
          GestureDetector(
            onTap: () => onTap(3),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  selectedIndex == 3
                      ? Icons.video_library
                      : Icons.video_library_outlined,
                  size: 30,
                  color: selectedIndex == 3
                      ? AppColors.textPrimary
                      : AppColors.textMuted,
                ),
                const SizedBox(height: AppDimensions.spaceExtraSmall),
                Text(
                  'Library',
                  style: AppTextStyles.caption.copyWith(
                    color: selectedIndex == 3
                        ? AppColors.textPrimary
                        : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),

          /// Upgrade
          GestureDetector(
            onTap: () => onTap(4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  selectedIndex == 4
                      ? Icons.workspace_premium
                      : Icons.workspace_premium_outlined,
                  size: 30,
                  color: selectedIndex == 4
                      ? AppColors.textPrimary
                      : AppColors.textMuted,
                ),
                const SizedBox(height: AppDimensions.spaceExtraSmall),
                Text(
                  'Upgrade',
                  style: AppTextStyles.caption.copyWith(
                    color: selectedIndex == 4
                        ? AppColors.textPrimary
                        : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
