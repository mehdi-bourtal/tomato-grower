import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/processor_info.dart';

class ProcessorMapCard extends StatefulWidget {
  final List<ProcessorInfo> processors;
  final void Function(ProcessorInfo)? onProcessorTap;

  const ProcessorMapCard({
    super.key,
    required this.processors,
    this.onProcessorTap,
  });

  @override
  State<ProcessorMapCard> createState() => _ProcessorMapCardState();
}

class _ProcessorMapCardState extends State<ProcessorMapCard> {
  final MapController _mapController = MapController();
  String? _selectedProcId;

  List<_MapPoint> get _mappableProcessors => widget.processors
      .map((p) {
        final latRaw = p.latitude;
        final lngRaw = p.longitude;
        if (latRaw == null || lngRaw == null) return null;

        final lat = double.tryParse(latRaw);
        final lng = double.tryParse(lngRaw);
        if (lat == null || lng == null) return null;
        if (!_isValidCoordinate(lat, lng)) return null;

        return _MapPoint(
          processor: p,
          point: LatLng(lat, lng),
        );
      })
      .whereType<_MapPoint>()
      .toList();

  bool _isValidCoordinate(double lat, double lng) {
    if (!lat.isFinite || !lng.isFinite) return false;
    if (lat < -90 || lat > 90) return false;
    if (lng < -180 || lng > 180) return false;
    return true;
  }

  /// Returns true when every marker shares the same coordinates. In that case
  /// [LatLngBounds.fromPoints] is degenerate and [CameraFit.bounds] can produce
  /// NaN/Infinity zoom (crash: "Infinity or NaN toInt").
  bool _allSameLocation(List<_MapPoint> procs) {
    if (procs.length <= 1) return true;
    final first = procs.first.point;
    return procs.every(
      (p) =>
          p.point.latitude == first.latitude &&
          p.point.longitude == first.longitude,
    );
  }

  LatLngBounds? _computeBounds(List<_MapPoint> procs) {
    if (procs.isEmpty) return null;
    if (_allSameLocation(procs)) return null;
    final points = procs.map((p) => p.point).toList();
    return LatLngBounds.fromPoints(points);
  }

  @override
  Widget build(BuildContext context) {
    final procs = _mappableProcessors;

    if (procs.isEmpty) {
      return Container(
        height: 180,
        decoration: BoxDecoration(
          color: AppColors.soil800,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.soil600),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                PhosphorIconsBold.mapPinLine,
                size: 32,
                color: AppColors.clay,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'No processor locations available',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.clay),
              ),
            ],
          ),
        ),
      );
    }

    final center = procs.first.point;
    final bounds = _computeBounds(procs);
    // Single location (one proc or several at same coords): fixed zoom only.
    final initialZoom = bounds == null ? 13.0 : 10.0;

    return Container(
      height: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.soil600),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: initialZoom,
              initialCameraFit: bounds != null
                  ? CameraFit.bounds(
                      bounds: bounds,
                      padding: const EdgeInsets.all(40),
                    )
                  : null,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
              onTap: (_, __) => setState(() => _selectedProcId = null),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}@2x.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.tomatogrower.app',
                tileProvider: NetworkTileProvider(),
              ),
              MarkerLayer(
                markers: procs.map((p) => _buildMarker(p.processor, p.point)).toList(),
              ),
            ],
          ),
          if (_selectedProcId != null)
            Positioned(
              left: AppSpacing.sm,
              right: AppSpacing.sm,
              bottom: AppSpacing.sm,
              child: _buildInfoBanner(
                procs.firstWhere((p) => p.processor.procId == _selectedProcId).processor,
              ),
            ),
          Positioned(
            top: AppSpacing.sm,
            right: AppSpacing.sm,
            child: Column(
              children: [
                _MapButton(
                  icon: PhosphorIconsBold.arrowsOut,
                  onTap: () {
                    if (bounds != null) {
                      _mapController.fitCamera(
                        CameraFit.bounds(
                          bounds: bounds,
                          padding: const EdgeInsets.all(40),
                        ),
                      );
                    } else if (procs.isNotEmpty) {
                      _mapController.move(procs.first.point, 13);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Marker _buildMarker(ProcessorInfo proc, LatLng point) {
    final isSelected = proc.procId == _selectedProcId;

    return Marker(
      point: point,
      width: isSelected ? 48 : 36,
      height: isSelected ? 48 : 36,
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedProcId = proc.procId);
          widget.onProcessorTap?.call(proc);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.leafGreen
                : AppColors.leafGreen.withValues(alpha: 0.85),
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? AppColors.cream : AppColors.sprout,
              width: isSelected ? 3 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.leafGreen.withValues(alpha: 0.4),
                blurRadius: isSelected ? 12 : 6,
              ),
            ],
          ),
          child: const Icon(
            PhosphorIconsBold.plant,
            color: AppColors.soil900,
            size: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBanner(ProcessorInfo proc) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        onTap: () => widget.onProcessorTap?.call(proc),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: AppColors.soil800.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(color: AppColors.leafGreen.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.leafGreen,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      proc.displayName,
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.cream,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${proc.latitude}° N, ${proc.longitude}° E',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.clay,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${proc.cultivationSize ?? '—'} plants',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.sprout,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Icon(
                PhosphorIconsBold.caretRight,
                size: 16,
                color: AppColors.clay,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapPoint {
  final ProcessorInfo processor;
  final LatLng point;

  const _MapPoint({
    required this.processor,
    required this.point,
  });
}

class _MapButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MapButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.soil800.withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Icon(icon, size: 18, color: AppColors.cream),
        ),
      ),
    );
  }
}
