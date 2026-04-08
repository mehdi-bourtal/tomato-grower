import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/app_date_utils.dart';
import '../../../data/models/tomato_status.dart';

class RipeAlertCard extends StatelessWidget {
  final TomatoStatus tomatoStatus;
  final VoidCallback? onViewPhoto;

  const RipeAlertCard({
    super.key,
    required this.tomatoStatus,
    this.onViewPhoto,
  });

  @override
  Widget build(BuildContext context) {
    final count = tomatoStatus.ripeTomatos ?? 0;
    if (count <= 0) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4A1A1A),
            Color(0xFF2D1010),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.tomatoRed.withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.tomatoRed.withOpacity(0.15),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.tomatoRed.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Center(
              child: Text('🍅', style: TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count ripe tomato${count > 1 ? 'es' : ''}!',
                  style: AppTypography.displayMedium.copyWith(
                    color: AppColors.tomatoRed,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Ready to harvest · ${AppDateUtils.timeAgo(tomatoStatus.date)}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.parchment.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          if (onViewPhoto != null)
            IconButton(
              onPressed: onViewPhoto,
              icon: const Icon(
                PhosphorIconsBold.camera,
                color: AppColors.tomatoRed,
              ),
              tooltip: 'View photo',
            ),
        ],
      ),
    );
  }
}
