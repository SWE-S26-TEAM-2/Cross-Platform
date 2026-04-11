import 'package:flutter/material.dart';
import 'package:my_project/constants/app_colors.dart';
import 'package:my_project/constants/app_dimensions.dart';
import 'package:my_project/constants/app_text_styles.dart';

class VibesSection extends StatelessWidget {
  const VibesSection({super.key});

  final List<Map<String, dynamic>> vibes = const [
    {"title": "Hip Hop & Rap", "color": Color(0xFF8B5CF6)},
    {"title": "Electronic", "color": Color(0xFFEC4899)},
    {"title": "Pop", "color": Color(0xFFFACC15)},
    {"title": "R&B", "color": Color(0xFF2DD4BF)},
    {"title": "Chill", "color": Color(0xFF2DD4BF)},
    {"title": "Party", "color": Color(0xFFFB923C)},
    {"title": "Workout", "color": Color(0xFF34D399)},
    {"title": "Techno", "color": Color(0xFFF472B6)},
    {"title": "House", "color": Color(0xFFF472B6)},
    {"title": "Feel Good", "color": Color(0xFFFACC15)},
    {"title": "At Home", "color": Color(0xFFA78BFA)},
    {"title": "Healing Era", "color": Color(0xFF60A5FA)},
    {"title": "Study", "color": Color(0xFFF472B6)},
    {"title": "Folk", "color": Color(0xFFFB923C)},
    {"title": "Indie", "color": Color(0xFF60A5FA)},
    {"title": "Soul", "color": Color(0xFF2DD4BF)},
    {"title": "Country", "color": Color(0xFFFB923C)},
    {"title": "Latin", "color": Color(0xFFEC4899)},
    {"title": "Rock", "color": Color(0xFFA78BFA)},
  ];

  double _tileHeight(int index) {
    switch (index % 3) {
      case 0:
        return 160;
      case 1:
        return 160;
      case 2:
        return 160;
      default:
        return 160;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spaceMedium, vertical: AppDimensions.spaceMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: AppDimensions.spaceMedium),
            child: Text(
              "Vibes",
              style: AppTextStyles.heading1
            ),
          ),
          Wrap(
            spacing: 12,
            runSpacing: AppDimensions.spaceMedium,
            children: List.generate(vibes.length, (index) {
              final vibe = vibes[index];

              return GestureDetector(
                onTap: () {},
                child: Container(
                  width: (MediaQuery.of(context).size.width / 2) - 22,
                  height: _tileHeight(index),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                        AppDimensions.borderRadiusMedium),
                    /*boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(2, 3),
                      ),
                    ],*/
                    color: AppColors.surface,
                    border: Border.all(color: vibe["color"], width: 1.2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        vibe["title"],
                        style: AppTextStyles.heading2,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}