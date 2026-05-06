import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/repositories/tomato_repository.dart';
import 'app_shimmer.dart';

class SupabaseImage extends StatefulWidget {
  final String? imagePath;
  final TomatoRepository tomatoRepo;
  final BoxFit fit;
  final double? height;
  final double? width;

  const SupabaseImage({
    super.key,
    required this.imagePath,
    required this.tomatoRepo,
    this.fit = BoxFit.cover,
    this.height,
    this.width,
  });

  @override
  State<SupabaseImage> createState() => _SupabaseImageState();
}

class _SupabaseImageState extends State<SupabaseImage> {
  String? _signedUrl;
  bool _loading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _resolveUrl();
  }

  @override
  void didUpdateWidget(SupabaseImage old) {
    super.didUpdateWidget(old);
    if (old.imagePath != widget.imagePath) _resolveUrl();
  }

  Future<void> _resolveUrl() async {
    if (widget.imagePath == null || widget.imagePath!.isEmpty) {
      if (mounted) setState(() { _loading = false; _hasError = true; });
      return;
    }
    setState(() { _loading = true; _hasError = false; });
    try {
      final url = await widget.tomatoRepo.getSignedImageUrl(widget.imagePath);
      if (mounted) {
        setState(() {
          _signedUrl = url;
          _loading = false;
          _hasError = url == null;
        });
      }
    } catch (_) {
      if (mounted) setState(() { _loading = false; _hasError = true; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return AppShimmer(
        height: widget.height ?? 120,
        width: widget.width ?? double.infinity,
        borderRadius: AppRadius.sm,
      );
    }

    if (_hasError || _signedUrl == null) {
      return Container(
        height: widget.height,
        width: widget.width ?? double.infinity,
        color: AppColors.soil700,
        child: const Center(
          child: Icon(Icons.image_not_supported_outlined, color: AppColors.clay),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: _signedUrl!,
      fit: widget.fit,
      height: widget.height,
      width: widget.width,
      placeholder: (_, __) => AppShimmer(
        height: widget.height ?? 120,
        width: widget.width ?? double.infinity,
        borderRadius: AppRadius.sm,
      ),
      errorWidget: (_, __, ___) => Container(
        height: widget.height,
        width: widget.width ?? double.infinity,
        color: AppColors.soil700,
        child: const Center(
          child: Icon(Icons.broken_image_outlined, color: AppColors.clay),
        ),
      ),
    );
  }
}
