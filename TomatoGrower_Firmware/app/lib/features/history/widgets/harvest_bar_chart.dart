import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/app_date_utils.dart';
import '../../../data/models/tomato_status.dart';

class HarvestBarChart extends StatelessWidget {
  final List<TomatoStatus> data;
  final Duration rangeDuration;

  const HarvestBarChart({
    super.key,
    required this.data,
    required this.rangeDuration,
  });

  @override
  Widget build(BuildContext context) {
    final filtered = data.where((e) => e.ripeTomatos != null).toList();

    if (filtered.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xl,
        ),
        decoration: BoxDecoration(
          color: AppColors.soil800,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.soil600),
        ),
        child: Row(
          children: [
            const Icon(Icons.bar_chart, size: 32, color: AppColors.clay),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'No harvest data',
                    style: AppTypography.titleMedium.copyWith(color: AppColors.parchment),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'No ripe tomato data for this period.',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.clay),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final maxRipe = filtered
        .map((e) => e.ripeTomatos!)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();

    return Container(
      height: 160,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.soil800,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.soil600),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Harvest Tracker',
            style: AppTypography.titleLarge.copyWith(color: AppColors.cream),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: BarChart(
              BarChartData(
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => AppColors.soil700,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${rod.toY.toInt()} ripe',
                        AppTypography.bodySmall.copyWith(
                          color: AppColors.cream,
                        ),
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
                        final idx = value.toInt();
                        if (idx < 0 || idx >= filtered.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            AppDateUtils.formatChartLabel(
                              filtered[idx].date,
                              rangeDuration,
                            ),
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
                maxY: maxRipe + 2,
                barGroups: filtered.asMap().entries.map((e) {
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: e.value.ripeTomatos!.toDouble(),
                        color: AppColors.tomatoRed,
                        width: 12,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxRipe + 2,
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
}
