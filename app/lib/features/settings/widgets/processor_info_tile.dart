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
  final VoidCallback? onRename;
  final VoidCallback? onEditLocation;

  const ProcessorInfoTile({
    super.key,
    required this.processor,
    this.onTap,
    this.onRename,
    this.onEditLocation,
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
                const Icon(
                  PhosphorIconsBold.cpu,
                  size: 24,
                  color: AppColors.leafGreenLight,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        processor.displayName,
                        style: AppTypography.titleLarge.copyWith(
                          color: AppColors.cream,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (!processor.hasName)
                        Text(
                          'No name set',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.clay,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                ),
                if (onRename != null)
                  IconButton(
                    onPressed: onRename,
                    icon: const Icon(
                      PhosphorIconsBold.pencilSimple,
                      size: 18,
                      color: AppColors.leafGreenLight,
                    ),
                    tooltip: 'Rename',
                    visualDensity: VisualDensity.compact,
                  ),
                const SizedBox(width: AppSpacing.xs),
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
            Row(
              children: [
                const Icon(
                  PhosphorIconsBold.mapPin,
                  size: 16,
                  color: AppColors.clay,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    (processor.latitude != null && processor.longitude != null)
                        ? '${processor.latitude}° N, ${processor.longitude}° E'
                        : 'No location set',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.clay,
                      fontStyle:
                          (processor.latitude == null) ? FontStyle.italic : null,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (onEditLocation != null)
                  IconButton(
                    onPressed: onEditLocation,
                    icon: const Icon(
                      PhosphorIconsBold.mapPinPlus,
                      size: 18,
                      color: AppColors.leafGreenLight,
                    ),
                    tooltip: 'Edit location',
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  PhosphorIconsBold.dropHalf,
                  size: 16,
                  color: AppColors.water,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    '${processor.wateringVolume ?? "—"} mL / watering · ${processor.cultivationSize ?? "—"} plants',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.water,
                    ),
                    overflow: TextOverflow.ellipsis,
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
