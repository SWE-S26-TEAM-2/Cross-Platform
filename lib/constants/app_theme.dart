// lib/constants/app_theme.dart

import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_dimensions.dart';

class AppTheme {
  // Called once in main.dart via: theme: AppTheme.darkTheme
  static ThemeData get darkTheme => ThemeData(
    // ─── BRIGHTNESS ─────────────────────────────────────────
    // Tells Flutter this is a dark theme
    brightness: Brightness.dark,

    // ─── BACKGROUND ─────────────────────────────────────────
    scaffoldBackgroundColor: AppColors.background,

    // ─── PRIMARY COLOR ──────────────────────────────────────
    // Used by sliders, progress indicators, checkboxes
    primaryColor: AppColors.primary,

    // ─── COLOR SCHEME ───────────────────────────────────────
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      surface: AppColors.surface,
      background: AppColors.background,
      onPrimary: AppColors.textPrimary,
      onSurface: AppColors.textPrimary,
      onBackground: AppColors.textPrimary,
    ),

    // ─── APPBAR ─────────────────────────────────────────────
    // Individual screens override this when needed
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.textPrimary, size: 24),
      titleTextStyle: AppTextStyles.heading2,
    ),

    // ─── BOTTOM NAVIGATION BAR ──────────────────────────────
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textMuted,
      selectedLabelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w400,
      ),
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    ),

    // ─── TEXT ───────────────────────────────────────────────
    textTheme: const TextTheme(
      displayLarge: AppTextStyles.heading1,
      displayMedium: AppTextStyles.heading2,
      bodyLarge: AppTextStyles.trackTitle,
      bodyMedium: AppTextStyles.artistName,
      bodySmall: AppTextStyles.caption,
      labelLarge: AppTextStyles.button,
    ),

    // ─── ICON THEME ─────────────────────────────────────────
    iconTheme: const IconThemeData(color: AppColors.textPrimary, size: 24),

    // ─── DIVIDER ────────────────────────────────────────────
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
      indent: AppDimensions.spaceMedium,
    ),

    // ─── ELEVATED BUTTON ────────────────────────────────────
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusPill),
        ),
        textStyle: AppTextStyles.button,
        minimumSize: const Size(0, 44),
      ),
    ),

    // ─── OUTLINED BUTTON ────────────────────────────────────
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: AppColors.textMuted, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusPill),
        ),
        textStyle: AppTextStyles.button,
        minimumSize: const Size(0, 44),
      ),
    ),

    // ─── SLIDER ─────────────────────────────────────────────
    sliderTheme: const SliderThemeData(
      activeTrackColor: AppColors.primary,
      inactiveTrackColor: AppColors.waveformInactive,
      thumbColor: AppColors.primary,
      overlayColor: Colors.transparent,
      trackHeight: 2,
      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
    ),
  );
}
