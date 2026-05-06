import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/app_date_utils.dart';
import '../../../data/models/watering_event.dart';

class WateringTimeline extends StatelessWidget {
  final List<WateringEvent> waterings;
  final int? volumePerWatering;

  const WateringTimeline({
    super.key,
    required this.waterings,
    this.volumePerWatering,
  });

  @override
  Widget build(BuildContext context) {
    if (waterings.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.soil800,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.soil600),
        ),
        child: Row(
          children: [
            Icon(PhosphorIconsBold.dropHalf, size: 24, color: AppColors.water.withOpacity(0.4)),
            const SizedBox(width: AppSpacing.md),
            Text(
              'No watering recorded yet',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.clay),
            ),
          ],
        ),
      );
    }

    final totalVolume = volumePerWatering != null
        ? volumePerWatering! * waterings.length
        : null;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.soil800,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.soil600),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.water.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Icon(PhosphorIconsBold.dropHalf, size: 18, color: AppColors.water),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent Waterings',
                      style: AppTypography.titleMedium.copyWith(color: AppColors.cream),
                    ),
                    if (totalVolume != null)
                      Text(
                        '${waterings.length} sessions · ${totalVolume} mL total',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.clay),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ...waterings.take(5).map((w) => _WateringRow(
                event: w,
                volume: volumePerWatering,
              )),
        ],
      ),
    );
  }
}

class _WateringRow extends StatelessWidget {
  final WateringEvent event;
  final int? volume;

  const _WateringRow({required this.event, this.volume});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.water,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          const Icon(PhosphorIconsBold.drop, size: 14, color: AppColors.water),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              AppDateUtils.formatTimestamp(event.date),
              style: AppTypography.bodySmall.copyWith(color: AppColors.parchment),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (volume != null)
            Text(
              '$volume mL',
              style: AppTypography.labelSmall.copyWith(color: AppColors.water),
            ),
        ],
      ),
    );
  }
}
