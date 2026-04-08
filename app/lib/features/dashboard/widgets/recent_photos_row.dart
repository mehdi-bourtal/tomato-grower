import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/app_date_utils.dart';
import '../../../data/models/tomato_status.dart';
import '../../../data/repositories/tomato_repository.dart';
import '../../../shared/widgets/supabase_image.dart';

class RecentPhotosRow extends StatelessWidget {
  final List<TomatoStatus> photos;
  final TomatoRepository tomatoRepo;

  const RecentPhotosRow({
    super.key,
    required this.photos,
    required this.tomatoRepo,
  });

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) {
      return SizedBox(
        height: 160,
        child: Center(
          child: Text(
            'No photos yet',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.clay),
          ),
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        itemCount: photos.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.lg),
        itemBuilder: (context, index) {
          final photo = photos[index];
          return _PhotoCard(
            photo: photo,
            tomatoRepo: tomatoRepo,
          );
        },
      ),
    );
  }
}

class _PhotoCard extends StatelessWidget {
  final TomatoStatus photo;
  final TomatoRepository tomatoRepo;

  const _PhotoCard({
    required this.photo,
    required this.tomatoRepo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      decoration: BoxDecoration(
        color: AppColors.soil800,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.soil600),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.md),
            ),
            child: SizedBox(
              height: 110,
              width: double.infinity,
              child: SupabaseImage(
                imagePath: photo.imgSupabaseUrl,
                tomatoRepo: tomatoRepo,
                fit: BoxFit.cover,
                height: 110,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppDateUtils.formatTimestamp(photo.date),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.clay,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      PhosphorIconsBold.orangeSlice,
                      size: 14,
                      color: AppColors.tomatoRed,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        photo.ripeTomatos != null
                            ? '${photo.ripeTomatos} ripe'
                            : '— ripe',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.cream,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
