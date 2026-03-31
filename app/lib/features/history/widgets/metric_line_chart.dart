import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/app_date_utils.dart';
import '../../../data/models/culture_info.dart';
import '../../../shared/widgets/empty_state.dart';

class MetricLineChart extends StatelessWidget {
  final List<CultureInfo> data;
  final Set<String> selectedMetrics;
  final Duration rangeDuration;

  const MetricLineChart({
    super.key,
    required this.data,
    required this.selectedMetrics,
    required this.rangeDuration,
  });

  static const _metricColors = {
    'temperature': AppColors.tomatoOrange,
    'humidity_air': AppColors.water,
    'humidity_ground': AppColors.leafGreen,
    'luminosity': AppColors.sunYellow,
    'pressure': AppColors.clay,
  };

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox(
        height: 240,
        child: EmptyState(
          icon: Icons.show_chart,
          title: 'No data',
          subtitle: 'No metrics available for this period.',
        ),
      );
    }

    final lines = <LineChartBarData>[];
    final startTime = data.first.date.millisecondsSinceEpoch.toDouble();

    for (final metric in selectedMetrics) {
      final spots = <FlSpot>[];
      for (final entry in data) {
        final x = (entry.date.millisecondsSinceEpoch.toDouble() - startTime) /
            1000 /
            60;
        final y = _getValue(entry, metric);
        if (y != null) {
          spots.add(FlSpot(x, y));
        }
      }
      if (spots.isEmpty) continue;

      final color = _metricColors[metric] ?? AppColors.clay;
      lines.add(
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: color,
          barWidth: 2,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: color.withOpacity(0.1),
          ),
        ),
      );
    }

    if (lines.isEmpty) {
      return const SizedBox(
        height: 240,
        child: EmptyState(
          icon: Icons.show_chart,
          title: 'No data',
          subtitle: 'Select metrics to display.',
        ),
      );
    }

    return Container(
      height: 240,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.soil800,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.soil600),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: AppColors.soil600,
              strokeWidth: 0.5,
              dashArray: [4, 4],
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.clay,
                  ),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: _getXInterval(),
                getTitlesWidget: (value, meta) {
                  final ms = startTime + value * 60 * 1000;
                  final dt =
                      DateTime.fromMillisecondsSinceEpoch(ms.toInt());
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      AppDateUtils.formatChartLabel(dt, rangeDuration),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.clay,
                        fontSize: 9,
                      ),
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => AppColors.soil700,
              tooltipRoundedRadius: AppRadius.sm,
              getTooltipItems: (spots) => spots.map((s) {
                final color = s.bar.color ?? AppColors.cream;
                return LineTooltipItem(
                  s.y.toStringAsFixed(1),
                  AppTypography.bodySmall.copyWith(color: color),
                );
              }).toList(),
            ),
          ),
          lineBarsData: lines,
        ),
      ),
    );
  }

  double? _getValue(CultureInfo entry, String metric) {
    switch (metric) {
      case 'temperature':
        return entry.temperature;
      case 'humidity_air':
        return entry.humidityAir?.toDouble();
      case 'humidity_ground':
        return entry.humidityGround?.toDouble();
      case 'luminosity':
        return entry.luminosity?.toDouble();
      case 'pressure':
        return entry.pressure?.toDouble();
      default:
        return null;
    }
  }

  double _getXInterval() {
    if (rangeDuration.inHours <= 24) return 60;
    if (rangeDuration.inDays <= 7) return 60 * 24;
    return 60 * 24 * 5;
  }
}
