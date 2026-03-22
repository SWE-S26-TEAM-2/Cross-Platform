import 'package:flutter/material.dart';
import 'package:my_project/constants/app_colors.dart';
import 'package:my_project/constants/app_dimensions.dart';

class SearchBar1 extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onChanged;

  const SearchBar1({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  State<SearchBar1> createState() => _SearchBar1State();
}

class _SearchBar1State extends State<SearchBar1> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spaceMedium,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spaceMedium,
          vertical: AppDimensions.spaceExtraSmall,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusPill),
        ),
        child: Row(
          children: [
            const Icon(Icons.search),
            const SizedBox(width: AppDimensions.spaceSmall),
            Expanded(
              child: TextField(
                controller: widget.controller,
                onChanged: widget.onChanged,
                decoration: const InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                  border: InputBorder.none,
                ),
                cursorColor: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
