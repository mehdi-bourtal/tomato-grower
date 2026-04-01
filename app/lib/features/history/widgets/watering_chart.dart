import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/app_date_utils.dart';
import '../../../data/models/watering_event.dart';

class WateringChart extends StatelessWidget {
  final List<WateringEvent> data;
  final int? volumePerWatering;
  final Duration rangeDuration;

  const WateringChart({
    super.key,
    required this.data,
    this.volumePerWatering,
    required this.rangeDuration,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Container(
        height: 180,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.soil800,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.soil600),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const Expanded(
              child: Center(
                child: Text(
                  'No watering during this period',
                  style: TextStyle(color: AppColors.clay),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final grouped = _groupByDay(data);
    final maxCount = grouped.values.reduce((a, b) => a > b ? a : b).toDouble();

    return Container(
      height: 200,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.soil800,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.soil600),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: BarChart(
              BarChartData(
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => AppColors.soil700,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final count = rod.toY.toInt();
                      final vol = volumePerWatering != null
                          ? ' (${volumePerWatering! * count} mL)'
                          : '';
                      return BarTooltipItem(
                        '$count watering${count > 1 ? 's' : ''}$vol',
                        AppTypography.bodySmall.copyWith(color: AppColors.cream),
                      );
                    },
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final keys = grouped.keys.toList();
                        final idx = value.toInt();
                        if (idx < 0 || idx >= keys.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            AppDateUtils.formatChartLabel(keys[idx], rangeDuration),
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.clay,
                              fontSize: 9,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                maxY: maxCount + 1,
                barGroups: grouped.entries.toList().asMap().entries.map((e) {
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: e.value.value.toDouble(),
                        color: AppColors.water,
                        width: grouped.length > 20 ? 6 : 12,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxCount + 1,
                          color: AppColors.soil700,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final totalVolume = volumePerWatering != null
        ? volumePerWatering! * data.length
        : null;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.water.withOpacity(0.12),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: const Icon(PhosphorIconsBold.dropHalf, size: 18, color: AppColors.water),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Watering History',
                style: AppTypography.titleMedium.copyWith(color: AppColors.cream),
              ),
              if (totalVolume != null)
                Text(
                  '${data.length} sessions · ${totalVolume} mL',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.clay),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Map<DateTime, int> _groupByDay(List<WateringEvent> events) {
    final map = <DateTime, int>{};
    for (final e in events) {
      final day = DateTime(e.date.year, e.date.month, e.date.day);
      map[day] = (map[day] ?? 0) + 1;
    }
    return Map.fromEntries(
      map.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }
}
