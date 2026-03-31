import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/app_date_utils.dart';
import '../../../data/models/tomato_status.dart';
import '../../../data/repositories/tomato_repository.dart';
import '../../../shared/widgets/app_shimmer.dart';

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
          final imageUrl = tomatoRepo.getPublicImageUrl(photo.imgSupabaseUrl);

          return _PhotoCard(
            imageUrl: imageUrl,
            date: photo.date,
            ripeCount: photo.ripeTomatos,
          );
        },
      ),
    );
  }
}

class _PhotoCard extends StatelessWidget {
  final String? imageUrl;
  final DateTime date;
  final int? ripeCount;

  const _PhotoCard({
    this.imageUrl,
    required this.date,
    this.ripeCount,
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
              child: imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const AppShimmer(height: 110),
                      errorWidget: (_, __, ___) => Container(
                        color: AppColors.soil700,
                        child: const Icon(
                          Icons.broken_image_outlined,
                          color: AppColors.clay,
                        ),
                      ),
                    )
                  : Container(
                      color: AppColors.soil700,
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        color: AppColors.clay,
                      ),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppDateUtils.formatTimestamp(date),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.clay,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      PhosphorIconsBold.orangeSlice,
                      size: 14,
                      color: AppColors.tomatoRed,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      ripeCount != null
                          ? '$ripeCount ripe'
                          : '— ripe',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.cream,
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
