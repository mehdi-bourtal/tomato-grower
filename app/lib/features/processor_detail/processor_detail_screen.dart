import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/app_date_utils.dart';
import '../../core/utils/unit_conversion.dart';
import '../../data/models/culture_info.dart';
import '../../data/models/processor_info.dart';
import '../../data/models/watering_event.dart';
import '../../data/providers/supabase_provider.dart';
import '../../shared/widgets/app_shimmer.dart';
import '../../shared/widgets/empty_state.dart';
import '../dashboard/widgets/watering_timeline.dart';

final _processorProvider =
    FutureProvider.family<ProcessorInfo?, String>((ref, procId) async {
  final repo = ref.watch(processorRepositoryProvider);
  return repo.fetchById(procId);
});

final _recentMetricsProvider =
    FutureProvider.family<List<CultureInfo>, String>((ref, procId) async {
  final repo = ref.watch(cultureRepositoryProvider);
  return repo.fetchRecentForProcessor(procId, limit: 5);
});

final _recentWateringsProvider =
    FutureProvider.family<List<WateringEvent>, String>((ref, procId) async {
  final repo = ref.watch(wateringRepositoryProvider);
  return repo.fetchRecent(procId, limit: 5);
});

class ProcessorDetailScreen extends ConsumerWidget {
  final String procId;

  const ProcessorDetailScreen({super.key, required this.procId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final procAsync = ref.watch(_processorProvider(procId));
    final metricsAsync = ref.watch(_recentMetricsProvider(procId));
    final wateringsAsync = ref.watch(_recentWateringsProvider(procId));

    return Scaffold(
      backgroundColor: AppColors.soil900,
      appBar: AppBar(
        backgroundColor: AppColors.soil900,
        foregroundColor: AppColors.cream,
        title: procAsync.when(
          data: (p) => Text(
            p?.displayName ?? 'Processor',
            style: AppTypography.titleLarge.copyWith(color: AppColors.cream),
          ),
          loading: () => const Text('Loading…'),
          error: (_, __) => const Text('Processor'),
        ),
      ),
      body: procAsync.when(
        data: (proc) {
          if (proc == null) {
            return const EmptyState(
              icon: PhosphorIconsBold.cpu,
              title: 'Processor not found',
              subtitle: 'This processor may have been removed.',
            );
          }

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            children: [
              _buildMap(proc),
              const SizedBox(height: AppSpacing.xl),
              _buildInfoSection(proc),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Recent Metrics',
                style: AppTypography.displayMedium.copyWith(
                  color: AppColors.cream,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              metricsAsync.when(
                data: (metrics) => _buildMetricsList(metrics),
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.leafGreen),
                ),
                error: (e, _) => Text(
                  'Error: $e',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.tomatoRed,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              wateringsAsync.when(
                data: (waterings) => WateringTimeline(
                  waterings: waterings,
                  volumePerWatering: proc.wateringVolume,
                ),
                loading: () => const SizedBox(
                  height: 80,
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.water),
                  ),
                ),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Watering coming soon!'),
                      ),
                    );
                  },
                  icon: const Icon(PhosphorIconsBold.dropHalf, size: 20),
                  label: const Text('Water Now'),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.leafGreen),
        ),
        error: (e, _) => EmptyState(
          icon: Icons.error_outline,
          title: 'Error',
          subtitle: e.toString(),
        ),
      ),
    );
  }

  Widget _buildMap(ProcessorInfo proc) {
    if (proc.latitude == null || proc.longitude == null) {
      return Container(
        height: 180,
        decoration: BoxDecoration(
          color: AppColors.soil800,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.soil600),
        ),
        child: const Center(
          child: Icon(
            PhosphorIconsBold.mapPin,
            size: 48,
            color: AppColors.clay,
          ),
        ),
      );
    }

    final lat = proc.latitude!;
    final lon = proc.longitude!;
    final url =
        'https://staticmap.openstreetmap.de/staticmap.php?center=$lat,$lon&zoom=14&size=600x300&maptype=mapnik&markers=$lat,$lon,lightblue';

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: SizedBox(
        height: 180,
        width: double.infinity,
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          placeholder: (_, __) => const AppShimmer(height: 180),
          errorWidget: (_, __, ___) => Container(
            color: AppColors.soil800,
            child: const Center(
              child: Icon(Icons.map, size: 48, color: AppColors.clay),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(ProcessorInfo proc) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.soil800,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.soil600),
      ),
      child: Column(
        children: [
          _infoRow('Name', proc.displayName),
          _infoRow(
            'Coordinates',
            proc.latitude != null && proc.longitude != null
                ? '${proc.latitude}°, ${proc.longitude}°'
                : '—',
          ),
          _infoRow(
            'Watering Volume',
            proc.wateringVolume != null ? '${proc.wateringVolume} mL' : '—',
          ),
          _infoRow(
            'Cultivation Size',
            proc.cultivationSize != null
                ? '${proc.cultivationSize} plants'
                : '—',
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.clay),
          ),
          Flexible(
            child: Text(
              value,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.cream),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsList(List<CultureInfo> metrics) {
    if (metrics.isEmpty) {
      return const EmptyState(
        icon: PhosphorIconsBold.thermometerSimple,
        title: 'No metrics yet',
        subtitle: 'Recent readings will appear here.',
      );
    }

    return Column(
      children: metrics.map((m) {
        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.soil800,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(color: AppColors.soil600),
          ),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.leafGreen,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppDateUtils.formatTimestamp(m.date),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.clay,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${UnitConversion.formatTemperature(m.temperature)}°C · '
                      '${UnitConversion.formatHumidity(m.humidityInt)}% · '
                      '${UnitConversion.formatInt(m.luminosity)} lux',
                      style: AppTypography.metricSmall.copyWith(
                        color: AppColors.cream,
                      ),
                    ),
                  ],
                ),
              ),
              if (m.error != null && m.error!.isNotEmpty)
                const Icon(
                  PhosphorIconsBold.warning,
                  size: 20,
                  color: AppColors.tomatoRed,
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
