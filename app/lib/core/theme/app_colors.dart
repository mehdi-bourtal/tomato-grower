import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Dark theme (primary)
  static const soil900 = Color(0xFF0F1A0F);
  static const soil800 = Color(0xFF1A2B1A);
  static const soil700 = Color(0xFF253825);
  static const soil600 = Color(0xFF34503A);
  static const leafGreen = Color(0xFF4CAF50);
  static const leafGreenLight = Color(0xFF81C784);
  static const sprout = Color(0xFFC8E6C9);
  static const tomatoRed = Color(0xFFE53935);
  static const tomatoOrange = Color(0xFFFF7043);
  static const sunYellow = Color(0xFFFFD54F);
  static const cream = Color(0xFFFFF8E1);
  static const parchment = Color(0xFFF5F0E1);
  static const clay = Color(0xFF8D6E63);
  static const water = Color(0xFF4FC3F7);
  static const waterDark = Color(0xFF0288D1);

  // Light theme overrides
  static const backgroundLight = Color(0xFFFBF8F0);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const textPrimaryLight = Color(0xFF1B2E1B);
  static const textSecondaryLight = Color(0xFF4E6E4E);
  static const dividerLight = Color(0xFFD7CFC0);

  // Semantic
  static const healthy = leafGreen;
  static const warning = tomatoOrange;
  static const critical = tomatoRed;
  static const info = water;
  static const inactive = soil600;

  static Color statusColor(String status) {
    switch (status) {
      case 'healthy':
        return healthy;
      case 'warning':
        return warning;
      case 'critical':
        return critical;
      case 'info':
        return info;
      default:
        return inactive;
    }
  }
}
