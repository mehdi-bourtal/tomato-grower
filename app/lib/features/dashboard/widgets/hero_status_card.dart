import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/app_date_utils.dart';
import '../../../core/utils/health_status.dart';
import '../../../data/models/culture_info.dart';
import '../../../data/models/processor_info.dart';
import '../../../data/models/tomato_status.dart';
import '../../../shared/widgets/app_shimmer.dart';

class HeroStatusCard extends StatelessWidget {
  final CultureInfo? metrics;
  final TomatoStatus? tomatoStatus;
  final ProcessorInfo? processor;
  final VoidCallback? onWaterNow;
  final VoidCallback? onViewPhoto;

  const HeroStatusCard({
    super.key,
    this.metrics,
    this.tomatoStatus,
    this.processor,
    this.onWaterNow,
    this.onViewPhoto,
  });

  @override
  Widget build(BuildContext context) {
    if (metrics == null && tomatoStatus == null && processor == null) {
      return const AppShimmerCard(height: 220);
    }

    final status = computeHealthStatus(metrics);
    final message = statusMessage(status);
    final statusColor = AppColors.statusColor(status);

    final ripeCount = tomatoStatus?.ripeTomatos;
    final cultivationSize = processor?.cultivationSize;
    final lastReading = metrics?.date;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.soil900, AppColors.soil800],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.soil600),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Icon(
              PhosphorIconsBold.plant,
              size: 48,
              color: statusColor,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            message,
            style: AppTypography.displayMedium.copyWith(color: statusColor),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _buildSubtitle(ripeCount, cultivationSize, lastReading),
            style: AppTypography.bodyMedium.copyWith(color: AppColors.parchment),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              FilledButton.icon(
                onPressed: onWaterNow,
                icon: Icon(PhosphorIconsBold.dropHalf, size: 18),
                label: const Text('Water Now'),
              ),
              const SizedBox(width: AppSpacing.md),
              OutlinedButton.icon(
                onPressed: onViewPhoto,
                icon: Icon(PhosphorIconsBold.camera, size: 18),
                label: const Text('View Photo'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _buildSubtitle(int? ripe, int? total, DateTime? lastDate) {
    final parts = <String>[];
    if (ripe != null) parts.add('$ripe ripe');
    if (total != null) parts.add('$total plants');
    if (lastDate != null) parts.add('Last reading ${AppDateUtils.timeAgo(lastDate)}');
    return parts.isEmpty ? 'Waiting for data…' : parts.join(' · ');
  }
}
