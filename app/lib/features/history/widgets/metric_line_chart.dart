import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/app_date_utils.dart';
import '../../../core/utils/unit_conversion.dart';
import '../../../data/models/culture_info.dart';

class MetricLineChart extends StatelessWidget {
  final List<CultureInfo> data;
  final String metricKey;
  final Duration rangeDuration;

  const MetricLineChart({
    super.key,
    required this.data,
    required this.metricKey,
    required this.rangeDuration,
  });

  static final _metricConfig = <String, ({String label, String unit, IconData icon, Color color})>{
    'temperature': (label: 'Temperature', unit: '°C', icon: PhosphorIconsBold.thermometerSimple, color: AppColors.tomatoOrange),
    'humidity_int': (label: 'Interior Humidity', unit: '%', icon: PhosphorIconsBold.drop, color: AppColors.water),
    'humidity_ext': (label: 'Exterior Humidity', unit: '%', icon: PhosphorIconsBold.cloudRain, color: AppColors.leafGreen),
    'luminosity': (label: 'Luminosity', unit: 'lux', icon: PhosphorIconsBold.sun, color: AppColors.sunYellow),
    'pressure': (label: 'Pressure', unit: 'hPa', icon: PhosphorIconsBold.gauge, color: AppColors.clay),
  };

  @override
  Widget build(BuildContext context) {
    final config = _metricConfig[metricKey];
    if (config == null) return const SizedBox.shrink();

    final spots = <FlSpot>[];
    final startTime = data.isNotEmpty
        ? data.first.date.millisecondsSinceEpoch.toDouble()
        : 0.0;

    for (final entry in data) {
      final x =
          (entry.date.millisecondsSinceEpoch.toDouble() - startTime) / 1000 / 60;
      final y = _getValue(entry);
      if (y != null) spots.add(FlSpot(x, y));
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.soil800,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.soil600),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: config.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(config.icon, size: 18, color: config.color),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  config.label,
                  style: AppTypography.titleMedium.copyWith(color: AppColors.cream),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.soil700,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  config.unit,
                  style: AppTypography.labelSmall.copyWith(color: config.color),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (spots.isEmpty)
            SizedBox(
              height: 140,
              child: Center(
                child: Text(
                  'No data for this period',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.clay),
                ),
              ),
            )
          else
            SizedBox(
              height: 160,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: _getYInterval(spots),
                    getDrawingHorizontalLine: (_) => const FlLine(
                      color: AppColors.soil600,
                      strokeWidth: 0.5,
                      dashArray: [4, 4],
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 44,
                        getTitlesWidget: (value, meta) {
                          if (value == meta.min || value == meta.max) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(
                              _formatYLabel(value),
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.clay,
                                fontSize: 9,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: _getXInterval(),
                        getTitlesWidget: (value, meta) {
                          if (value == meta.min || value == meta.max) {
                            return const SizedBox.shrink();
                          }
                          final ms = startTime + value * 60 * 1000;
                          final dt = DateTime.fromMillisecondsSinceEpoch(ms.toInt());
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
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (_) => AppColors.soil700,
                      tooltipRoundedRadius: AppRadius.sm,
                      getTooltipItems: (touchedSpots) => touchedSpots.map((s) {
                        return LineTooltipItem(
                          '${s.y.toStringAsFixed(1)} ${config.unit}',
                          AppTypography.bodySmall.copyWith(color: config.color),
                        );
                      }).toList(),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      preventCurveOverShooting: true,
                      color: config.color,
                      barWidth: 2,
                      dotData: FlDotData(
                        show: spots.length <= 30,
                        getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                          radius: 2,
                          color: config.color,
                          strokeWidth: 0,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            config.color.withOpacity(0.2),
                            config.color.withOpacity(0.02),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  double? _getValue(CultureInfo entry) {
    switch (metricKey) {
      case 'temperature':
        return entry.temperature;
      case 'humidity_int':
        return entry.humidityInt;
      case 'humidity_ext':
        return entry.humidityExt;
      case 'luminosity':
        return entry.luminosity?.toDouble();
      case 'pressure':
        return entry.pressure != null
            ? UnitConversion.pressureToHpa(entry.pressure!)
            : null;
      default:
        return null;
    }
  }

  String _formatYLabel(double value) {
    if (value >= 10000) return '${(value / 1000).toStringAsFixed(0)}k';
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(1);
  }

  double _getXInterval() {
    if (rangeDuration.inHours <= 24) return 60;
    if (rangeDuration.inDays <= 7) return 60 * 24;
    return 60 * 24 * 5;
  }

  double _getYInterval(List<FlSpot> spots) {
    if (spots.isEmpty) return 10;
    final yValues = spots.map((s) => s.y);
    final range = yValues.reduce((a, b) => a > b ? a : b) -
        yValues.reduce((a, b) => a < b ? a : b);
    if (range <= 0) return 10;
    if (range <= 10) return 2;
    if (range <= 50) return 10;
    if (range <= 200) return 50;
    if (range <= 1000) return 200;
    return (range / 5).roundToDouble();
  }
}
