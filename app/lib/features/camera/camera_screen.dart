import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/providers/supabase_provider.dart';
import '../../shared/widgets/empty_state.dart';
import 'providers/camera_provider.dart';
import 'widgets/photo_grid.dart';
import 'widgets/photo_viewer.dart';

class CameraScreen extends ConsumerWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photosAsync = ref.watch(allPhotosProvider);
    final tomatoRepo = ref.watch(tomatoRepositoryProvider);

    return Scaffold(
      backgroundColor: AppColors.soil900,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Text(
                'Gallery',
                style: AppTypography.displayLarge.copyWith(
                  color: AppColors.cream,
                ),
              ),
            ),
            Expanded(
              child: photosAsync.when(
                data: (photos) {
                  if (photos.isEmpty) {
                    return EmptyState(
                      icon: PhosphorIconsBold.camera,
                      title: 'No photos yet',
                      subtitle:
                          'Photos will appear here once your processor captures them.',
                    );
                  }

                  return PhotoGrid(
                    photos: photos,
                    tomatoRepo: tomatoRepo,
                    onPhotoTap: (index) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PhotoViewer(
                            photos: photos,
                            initialIndex: index,
                            tomatoRepo: tomatoRepo,
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.leafGreen),
                ),
                error: (e, _) => EmptyState(
                  icon: Icons.error_outline,
                  title: 'Error loading photos',
                  subtitle: e.toString(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
