import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/providers/refresh_provider.dart';
import '../../data/providers/supabase_provider.dart';
import '../../shared/widgets/empty_state.dart';
import 'providers/dashboard_provider.dart';
import 'widgets/hero_status_card.dart';
import 'widgets/metric_grid.dart';
import 'widgets/recent_photos_row.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _initSelectedProcessor();
  }

  Future<void> _initSelectedProcessor() async {
    final procs = await ref.read(processorsProvider.future);
    if (procs.isNotEmpty && ref.read(selectedProcessorProvider) == null) {
      ref.read(selectedProcessorProvider.notifier).state = procs.first;
    }
  }

  Future<void> _refresh() async {
    ref.read(refreshTriggerProvider.notifier).update((s) => s + 1);
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    final selectedProc = ref.watch(selectedProcessorProvider);
    final processorsAsync = ref.watch(processorsProvider);
    final procId = selectedProc?.procId;

    return Scaffold(
      backgroundColor: AppColors.soil900,
      body: RefreshIndicator(
        color: AppColors.leafGreen,
        backgroundColor: AppColors.soil800,
        onRefresh: _refresh,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + AppSpacing.lg,
                left: AppSpacing.xxl,
                right: AppSpacing.xxl,
              ),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Dashboard',
                      style: AppTypography.displayLarge.copyWith(
                        color: AppColors.cream,
                      ),
                    ),
                    _ProcessorChip(
                      processor: selectedProc,
                      allProcessors: processorsAsync,
                      onSelected: (p) {
                        ref.read(selectedProcessorProvider.notifier).state = p;
                      },
                    ),
                  ],
                ),
              ),
            ),
            if (procId != null) ...[
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxl,
                  vertical: AppSpacing.lg,
                ),
                sliver: SliverToBoxAdapter(
                  child: _buildHeroCard(procId),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Live Metrics',
                        style: AppTypography.displayMedium.copyWith(
                          color: AppColors.cream,
                        ),
                      ),
                      IconButton(
                        onPressed: _refresh,
                        icon: Icon(
                          PhosphorIconsBold.arrowClockwise,
                          color: AppColors.leafGreenLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxl,
                  vertical: AppSpacing.lg,
                ),
                sliver: SliverToBoxAdapter(child: _buildMetricGrid(procId)),
              ),
              SliverPadding(
                padding: const EdgeInsets.only(
                  left: AppSpacing.xxl,
                  right: AppSpacing.xxl,
                  top: AppSpacing.xl,
                ),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Recent Photos',
                    style: AppTypography.displayMedium.copyWith(
                      color: AppColors.cream,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.only(top: AppSpacing.lg),
                sliver: SliverToBoxAdapter(child: _buildPhotos(procId)),
              ),
            ] else
              SliverFillRemaining(
                child: processorsAsync.when(
                  data: (procs) => procs.isEmpty
                      ? EmptyState(
                          icon: PhosphorIconsBold.cpu,
                          title: 'No processors found',
                          subtitle:
                              'Connect a processor to start monitoring your tomatoes.',
                        )
                      : const SizedBox.shrink(),
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.leafGreen),
                  ),
                  error: (e, _) => EmptyState(
                    icon: Icons.error_outline,
                    title: 'Connection error',
                    subtitle: e.toString(),
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard(String procId) {
    final metricsAsync = ref.watch(latestMetricsProvider(procId));
    final tomatoAsync = ref.watch(latestTomatoStatusProvider(procId));
    final processor = ref.watch(selectedProcessorProvider);

    return metricsAsync.when(
      data: (metrics) {
        final tomato = tomatoAsync.valueOrNull;
        return HeroStatusCard(
          metrics: metrics,
          tomatoStatus: tomato,
          processor: processor,
          onWaterNow: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Watering coming soon!')),
            );
          },
          onViewPhoto: () => context.go('/camera'),
        );
      },
      loading: () => const HeroStatusCard(),
      error: (e, _) {
        _showError(e.toString());
        return const HeroStatusCard();
      },
    );
  }

  Widget _buildMetricGrid(String procId) {
    final metricsAsync = ref.watch(latestMetricsProvider(procId));
    final sparkAsync = ref.watch(sparklineDataProvider(procId));
    final celsius = ref.watch(temperatureUnitProvider);

    final metrics = metricsAsync.valueOrNull;
    final sparkline = sparkAsync.valueOrNull ?? {};

    return MetricGrid(
      metrics: metrics,
      sparklineData: sparkline,
      celsius: celsius,
    );
  }

  Widget _buildPhotos(String procId) {
    final photosAsync = ref.watch(recentPhotosProvider(procId));
    final tomatoRepo = ref.watch(tomatoRepositoryProvider);

    return photosAsync.when(
      data: (photos) => RecentPhotosRow(
        photos: photos,
        tomatoRepo: tomatoRepo,
      ),
      loading: () => const SizedBox(
        height: 200,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.leafGreen),
        ),
      ),
      error: (e, _) {
        _showError(e.toString());
        return const SizedBox(height: 200);
      },
    );
  }

  void _showError(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    });
  }
}

class _ProcessorChip extends StatelessWidget {
  final dynamic processor;
  final AsyncValue<dynamic> allProcessors;
  final Function(dynamic) onSelected;

  const _ProcessorChip({
    required this.processor,
    required this.allProcessors,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final procs = allProcessors.valueOrNull;
        if (procs == null || (procs as List).length <= 1) return;

        showModalBottomSheet(
          context: context,
          backgroundColor: AppColors.soil800,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.lg),
            ),
          ),
          builder: (ctx) => Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Processor',
                  style: AppTypography.titleLarge.copyWith(
                    color: AppColors.cream,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                ...procs.map(
                  (p) => ListTile(
                    leading: Icon(
                      PhosphorIconsBold.cpu,
                      color: AppColors.leafGreenLight,
                    ),
                    title: Text(
                      p.displayName,
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.cream,
                      ),
                    ),
                    onTap: () {
                      onSelected(p);
                      Navigator.pop(ctx);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.soil800,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(PhosphorIconsBold.cpu, size: 14, color: AppColors.leafGreenLight),
            const SizedBox(width: AppSpacing.xs),
            Text(
              processor?.displayName ?? '…',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.leafGreenLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
