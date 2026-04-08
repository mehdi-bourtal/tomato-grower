import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/app_date_utils.dart';
import '../../../data/models/tomato_status.dart';
import '../../../data/repositories/tomato_repository.dart';
import '../../../shared/widgets/supabase_image.dart';

class PhotoGrid extends StatelessWidget {
  final List<TomatoStatus> photos;
  final TomatoRepository tomatoRepo;
  final void Function(int index) onPhotoTap;

  const PhotoGrid({
    super.key,
    required this.photos,
    required this.tomatoRepo,
    required this.onPhotoTap,
  });

  @override
  Widget build(BuildContext context) {
    return MasonryGridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: AppSpacing.lg,
      crossAxisSpacing: AppSpacing.lg,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl,
        vertical: AppSpacing.lg,
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        final photo = photos[index];

        return GestureDetector(
          onTap: () => onPhotoTap(index),
          child: Container(
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
                  child: AspectRatio(
                    aspectRatio: 16 / 10,
                    child: SupabaseImage(
                      imagePath: photo.imgSupabaseUrl,
                      tomatoRepo: tomatoRepo,
                      fit: BoxFit.cover,
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
                              '${photo.ripeTomatos ?? "—"} ripe',
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
          ),
        );
      },
    );
  }
}
