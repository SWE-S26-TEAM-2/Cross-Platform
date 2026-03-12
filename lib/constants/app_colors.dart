import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFFF5500); // The iconic SC orange
  static const Color background = Color(
    0xFF0D0D0D,
  ); // Near-black, not pure black

  static const Color surface = Color(
    0xFF1A1A1A,
  ); // Cards sit on top of background

  static const Color surfaceLight = Color(
    0xFF2A2A2A,
  ); // Elevated cards (modals, etc)

  static const Color textPrimary = Color(0xFFFFFFFF); // Main readable text
  static const Color textSecondary = Color(
    0xFF999999,
  ); // Artist names, subtitles
  static const Color textMuted = Color(0xFF555555); // Timestamps, counts
  static const Color waveformActive = Color(
    0xFFFF5500,
  ); // Played portion of waveform
  static const Color waveformInactive = Color(0xFF333333); // Unplayed portion
  static const Color divider = Color(0xFF222222); // Subtle line separators
}
