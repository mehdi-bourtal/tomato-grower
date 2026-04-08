import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/app_date_utils.dart';
import '../../../data/models/tomato_status.dart';
import '../../../data/repositories/tomato_repository.dart';
import '../../../shared/widgets/supabase_image.dart';

class PhotoViewer extends StatefulWidget {
  final List<TomatoStatus> photos;
  final int initialIndex;
  final TomatoRepository tomatoRepo;

  const PhotoViewer({
    super.key,
    required this.photos,
    required this.initialIndex,
    required this.tomatoRepo,
  });

  @override
  State<PhotoViewer> createState() => _PhotoViewerState();
}

class _PhotoViewerState extends State<PhotoViewer> {
  late PageController _controller;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.cream,
        elevation: 0,
      ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.photos.length,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemBuilder: (context, index) {
              final photo = widget.photos[index];

              return InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Center(
                  child: SupabaseImage(
                    imagePath: photo.imgSupabaseUrl,
                    tomatoRepo: widget.tomatoRepo,
                    fit: BoxFit.contain,
                  ),
                ),
              );
            },
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                left: AppSpacing.xl,
                right: AppSpacing.xl,
                top: AppSpacing.lg,
                bottom: MediaQuery.of(context).padding.bottom + AppSpacing.lg,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppDateUtils.formatTimestamp(
                      widget.photos[_currentIndex].date,
                    ),
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.clay,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        PhosphorIconsBold.orangeSlice,
                        size: 20,
                        color: AppColors.tomatoRed,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          '${widget.photos[_currentIndex].ripeTomatos ?? "—"} ripe tomatoes detected',
                          style: AppTypography.bodyLarge.copyWith(
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
          ),
        ],
      ),
    );
  }
}
