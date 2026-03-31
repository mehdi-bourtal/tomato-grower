import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  AppTypography._();

  static TextStyle get displayLarge => GoogleFonts.dmSans(
        fontWeight: FontWeight.w700,
        fontSize: 32,
        height: 40 / 32,
        letterSpacing: -0.5,
      );

  static TextStyle get displayMedium => GoogleFonts.dmSans(
        fontWeight: FontWeight.w700,
        fontSize: 24,
        height: 32 / 24,
        letterSpacing: -0.25,
      );

  static TextStyle get titleLarge => GoogleFonts.dmSans(
        fontWeight: FontWeight.w600,
        fontSize: 20,
        height: 28 / 20,
        letterSpacing: 0,
      );

  static TextStyle get titleMedium => GoogleFonts.dmSans(
        fontWeight: FontWeight.w600,
        fontSize: 16,
        height: 24 / 16,
        letterSpacing: 0.1,
      );

  static TextStyle get bodyLarge => GoogleFonts.dmSans(
        fontWeight: FontWeight.w400,
        fontSize: 16,
        height: 24 / 16,
        letterSpacing: 0.15,
      );

  static TextStyle get bodyMedium => GoogleFonts.dmSans(
        fontWeight: FontWeight.w400,
        fontSize: 14,
        height: 20 / 14,
        letterSpacing: 0.25,
      );

  static TextStyle get bodySmall => GoogleFonts.dmSans(
        fontWeight: FontWeight.w400,
        fontSize: 12,
        height: 16 / 12,
        letterSpacing: 0.4,
      );

  static TextStyle get labelLarge => GoogleFonts.dmSans(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        height: 20 / 14,
        letterSpacing: 0.1,
      );

  static TextStyle get labelSmall => GoogleFonts.dmSans(
        fontWeight: FontWeight.w500,
        fontSize: 11,
        height: 16 / 11,
        letterSpacing: 0.5,
      );

  static TextStyle get metricValue => GoogleFonts.dmMono(
        fontWeight: FontWeight.w700,
        fontSize: 28,
        height: 34 / 28,
        letterSpacing: -0.5,
      );

  static TextStyle get metricUnit => GoogleFonts.dmMono(
        fontWeight: FontWeight.w400,
        fontSize: 14,
        height: 20 / 14,
        letterSpacing: 0,
      );

  static TextStyle get metricSmall => GoogleFonts.dmMono(
        fontWeight: FontWeight.w500,
        fontSize: 16,
        height: 22 / 16,
        letterSpacing: 0,
      );
}
