import 'package:flutter/material.dart';
import 'package:my_project/constants/app_colors.dart';
import 'package:my_project/constants/app_dimensions.dart';
import 'package:my_project/constants/app_text_styles.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(title: const Text("Feed")),
        body: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.spaceSmall,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spaceExtraLarge,
              ),
              decoration: const BoxDecoration(color: AppColors.background),
              child: TabBar(
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.borderRadiusPill,
                  ),
                  color: AppColors.surfaceLight,
                ),
                labelColor: AppColors.textPrimary,
                labelStyle: AppTextStyles.button,
                dividerColor: AppColors.background,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spaceExtraLarge,
                ),
                overlayColor: const WidgetStatePropertyAll(
                  AppColors.background,
                ),
                //unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: AppDimensions.spaceSmall,
                        horizontal: AppDimensions.spaceMedium,
                      ),
                      child: Text('Following'),
                    ),
                  ),
                  Tab(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: AppDimensions.spaceSmall,
                        horizontal: AppDimensions.spaceMedium,
                      ),
                      child: Text('Discover'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
