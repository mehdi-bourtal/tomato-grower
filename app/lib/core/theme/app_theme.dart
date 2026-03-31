import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_spacing.dart';

class AppTheme {
  AppTheme._();

  static final ColorScheme _darkColorScheme = const ColorScheme.dark().copyWith(
    primary: const Color(0xFF4CAF50),
    onPrimary: const Color(0xFF0F1A0F),
    primaryContainer: const Color(0xFF1A2B1A),
    onPrimaryContainer: const Color(0xFFC8E6C9),
    secondary: const Color(0xFF4FC3F7),
    onSecondary: const Color(0xFF0F1A0F),
    secondaryContainer: const Color(0xFF0288D1),
    onSecondaryContainer: const Color(0xFFE1F5FE),
    error: const Color(0xFFE53935),
    onError: const Color(0xFFFFF8E1),
    surface: const Color(0xFF1A2B1A),
    onSurface: const Color(0xFFFFF8E1),
    surfaceContainerHighest: const Color(0xFF253825),
    outline: const Color(0xFF34503A),
    outlineVariant: const Color(0xFF34503A),
  );

  static final ColorScheme _lightColorScheme =
      const ColorScheme.light().copyWith(
    primary: const Color(0xFF388E3C),
    onPrimary: const Color(0xFFFFFFFF),
    primaryContainer: const Color(0xFFC8E6C9),
    onPrimaryContainer: const Color(0xFF1B2E1B),
    secondary: const Color(0xFF0288D1),
    onSecondary: const Color(0xFFFFFFFF),
    error: const Color(0xFFC62828),
    onError: const Color(0xFFFFFFFF),
    surface: const Color(0xFFFFFFFF),
    onSurface: const Color(0xFF1B2E1B),
    surfaceContainerHighest: const Color(0xFFF5F0E1),
    outline: const Color(0xFFD7CFC0),
  );

  static ThemeData get dark => _buildTheme(_darkColorScheme, Brightness.dark);
  static ThemeData get light =>
      _buildTheme(_lightColorScheme, Brightness.light);

  static ThemeData _buildTheme(ColorScheme colorScheme, Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor:
          isDark ? AppColors.soil900 : AppColors.backgroundLight,
      textTheme: GoogleFonts.dmSansTextTheme(
        ThemeData(brightness: brightness).textTheme,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(color: colorScheme.outline, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          side: BorderSide(color: colorScheme.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? AppColors.soil700 : AppColors.surfaceLight,
        contentTextStyle: TextStyle(
          color: isDark ? AppColors.cream : AppColors.textPrimaryLight,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outline,
        thickness: 0.5,
        space: 0,
      ),
    );
  }
}
