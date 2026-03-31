import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/processor_info.dart';
import '../../../shared/widgets/status_dot.dart';

class ProcessorInfoTile extends StatelessWidget {
  final ProcessorInfo processor;
  final VoidCallback? onTap;

  const ProcessorInfoTile({
    super.key,
    required this.processor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
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
                Icon(
                  PhosphorIconsBold.cpu,
                  size: 24,
                  color: AppColors.leafGreenLight,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    processor.displayName,
                    style: AppTypography.titleLarge.copyWith(
                      color: AppColors.cream,
                    ),
                  ),
                ),
                const StatusDot(status: 'healthy'),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Online',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.leafGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            if (processor.latitude != null && processor.longitude != null)
              Row(
                children: [
                  Icon(
                    PhosphorIconsBold.mapPin,
                    size: 16,
                    color: AppColors.clay,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '${processor.latitude}° N, ${processor.longitude}° E',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.clay,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  PhosphorIconsBold.dropHalf,
                  size: 16,
                  color: AppColors.water,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '${processor.wateringVolume ?? "—"} mL / watering · ${processor.cultivationSize ?? "—"} plants',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.water,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
