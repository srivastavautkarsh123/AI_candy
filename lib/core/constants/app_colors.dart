import 'package:flutter/material.dart';

class AppColors {
  // Primary Candy AI Neon Pink / Magenta Palette
  static const Color primaryPink = Color(0xFFFF2A85);
  static const Color secondaryPurple = Color(0xFF9B30FF);
  static const Color accentCyan = Color(0xFF00F0FF);
  static const Color accentGold = Color(0xFFFFB800);

  // Dark Obsidian Backgrounds
  static const Color background = Color(0xFF0B0A10);
  static const Color surface = Color(0xFF151320);
  static const Color surfaceLight = Color(0xFF1E1B2E);
  static const Color cardBorder = Color(0xFF2D2844);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB4B0C8);
  static const Color textMuted = Color(0xFF6E6A85);

  // Status Colors
  static const Color onlineGreen = Color(0xFF00E676);
  static const Color errorRed = Color(0xFFFF4D6D);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryPink, secondaryPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0x000B0A10), Color(0xCC0B0A10), Color(0xFF0B0A10)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.3, 0.75, 1.0],
  );
}
