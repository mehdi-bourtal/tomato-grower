import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) context.go('/dashboard');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.soil900,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              PhosphorIconsBold.plant,
              size: 64,
              color: AppColors.leafGreenLight,
            )
                .animate()
                .fadeIn(duration: 600.ms)
                .scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1.0, 1.0),
                  curve: Curves.easeOutBack,
                  duration: 800.ms,
                ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Tomato Grower',
              style: AppTypography.displayLarge.copyWith(
                color: AppColors.leafGreenLight,
              ),
            )
                .animate(delay: 200.ms)
                .fadeIn(duration: 600.ms)
                .slideY(begin: 0.2, end: 0),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Cultivate smarter.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.clay,
              ),
            )
                .animate(delay: 400.ms)
                .fadeIn(duration: 600.ms),
          ],
        ),
      ),
    );
  }
}
