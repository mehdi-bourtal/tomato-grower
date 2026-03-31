import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/empty_state.dart';
import 'providers/history_provider.dart';
import 'widgets/date_range_selector.dart';
import 'widgets/harvest_bar_chart.dart';
import 'widgets/metric_line_chart.dart';
import 'widgets/raw_data_table.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  String _selectedRange = '7d';

  static final _metricLabels = {
    'temperature': ('Temperature', PhosphorIconsBold.thermometerSimple, AppColors.tomatoOrange),
    'humidity_air': ('Air Humidity', PhosphorIconsBold.drop, AppColors.water),
    'humidity_ground': ('Ground Humid.', PhosphorIconsBold.plant, AppColors.leafGreen),
    'luminosity': ('Luminosity', PhosphorIconsBold.sun, AppColors.sunYellow),
    'pressure': ('Pressure', PhosphorIconsBold.gauge, AppColors.clay),
  };

  void _onRangeChanged(String label) {
    setState(() => _selectedRange = label);
    final now = DateTime.now();
    Duration dur;
    switch (label) {
      case '24h':
        dur = const Duration(hours: 24);
        break;
      case '30d':
        dur = const Duration(days: 30);
        break;
      default:
        dur = const Duration(days: 7);
    }
    ref.read(dateRangeProvider.notifier).state = DateTimeRange(
      start: now.subtract(dur),
      end: now,
    );
  }

  Future<void> _pickCustomRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      initialDateRange: ref.read(dateRangeProvider),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.leafGreen,
                  onPrimary: AppColors.soil900,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedRange = 'Custom');
      ref.read(dateRangeProvider.notifier).state = picked;
    }
  }

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(historyDataProvider);
    final harvestAsync = ref.watch(harvestDataProvider);
    final selectedMetrics = ref.watch(selectedMetricsProvider);
    final dateRange = ref.watch(dateRangeProvider);
    final rangeDuration = dateRange.end.difference(dateRange.start);

    return Scaffold(
      backgroundColor: AppColors.soil900,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          children: [
            Text(
              'History',
              style: AppTypography.displayLarge.copyWith(
                color: AppColors.cream,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            DateRangeSelector(
              selected: _selectedRange,
              onChanged: _onRangeChanged,
              onCustom: _pickCustomRange,
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildMetricToggleRow(selectedMetrics),
            const SizedBox(height: AppSpacing.xl),
            historyAsync.when(
              data: (data) => MetricLineChart(
                data: data,
                selectedMetrics: selectedMetrics,
                rangeDuration: rangeDuration,
              ),
              loading: () => const SizedBox(
                height: 240,
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.leafGreen),
                ),
              ),
              error: (e, _) => SizedBox(
                height: 240,
                child: EmptyState(
                  icon: Icons.error_outline,
                  title: 'Error',
                  subtitle: e.toString(),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            harvestAsync.when(
              data: (data) => HarvestBarChart(
                data: data,
                rangeDuration: rangeDuration,
              ),
              loading: () => const SizedBox(
                height: 160,
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.leafGreen),
                ),
              ),
              error: (e, _) => SizedBox(
                height: 160,
                child: EmptyState(
                  icon: Icons.error_outline,
                  title: 'Error',
                  subtitle: e.toString(),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            historyAsync.when(
              data: (data) => RawDataTable(data: data),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricToggleRow(Set<String> selected) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _metricLabels.entries.map((entry) {
          final key = entry.key;
          final (label, icon, color) = entry.value;
          final isActive = selected.contains(key);

          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: GestureDetector(
              onTap: () {
                final current = Set<String>.from(selected);
                if (isActive) {
                  current.remove(key);
                } else {
                  current.add(key);
                }
                ref.read(selectedMetricsProvider.notifier).state = current;
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: isActive ? color.withOpacity(0.12) : AppColors.soil700,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: isActive
                      ? Border.all(color: color, width: 1.5)
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 16, color: isActive ? color : AppColors.clay),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      label,
                      style: AppTypography.labelSmall.copyWith(
                        color: isActive ? color : AppColors.parchment,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
