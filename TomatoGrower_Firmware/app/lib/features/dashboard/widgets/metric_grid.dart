import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/unit_conversion.dart';
import '../../../data/models/culture_info.dart';
import 'metric_card.dart';

class MetricGrid extends StatelessWidget {
  final CultureInfo? metrics;
  final Map<String, List<double>> sparklineData;
  final bool celsius;

  const MetricGrid({
    super.key,
    required this.metrics,
    required this.sparklineData,
    this.celsius = true,
  });

  String _metricStatus(double? value, double min, double max) {
    if (value == null) return 'inactive';
    if (value < min || value > max) return 'warning';
    return 'healthy';
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    int crossAxisCount = 2;
    if (width > 840) {
      crossAxisCount = 4;
    } else if (width > 600) {
      crossAxisCount = 3;
    }

    final cards = <Widget>[
      MetricCard(
        title: 'Temperature',
        icon: PhosphorIconsBold.thermometerSimple,
        value: UnitConversion.formatTemperature(
          metrics?.temperature,
          celsius: celsius,
        ),
        unit: celsius ? '°C' : '°F',
        metricColor: AppColors.tomatoOrange,
        sparklineData: sparklineData['temperature'],
        status: _metricStatus(metrics?.temperature, 10, 40),
      ),
      MetricCard(
        title: 'Interior Humidity',
        icon: PhosphorIconsBold.drop,
        value: UnitConversion.formatHumidity(metrics?.humidityInt),
        unit: '%',
        metricColor: AppColors.water,
        sparklineData: sparklineData['humidity_int'],
        status: _metricStatus(metrics?.humidityInt, 30, 90),
      ),
      MetricCard(
        title: 'Exterior Humidity',
        icon: PhosphorIconsBold.cloudRain,
        value: UnitConversion.formatHumidity(metrics?.humidityExt),
        unit: '%',
        metricColor: AppColors.leafGreen,
        sparklineData: sparklineData['humidity_ext'],
        status: _metricStatus(metrics?.humidityExt, 20, 80),
      ),
      MetricCard(
        title: 'Luminosity',
        icon: PhosphorIconsBold.sun,
        value: UnitConversion.formatInt(metrics?.luminosity),
        unit: 'lux',
        metricColor: AppColors.sunYellow,
        sparklineData: sparklineData['luminosity'],
        status: 'healthy',
      ),
      MetricCard(
        title: 'Pressure',
        icon: PhosphorIconsBold.gauge,
        value: UnitConversion.formatPressure(metrics?.pressure),
        unit: 'hPa',
        metricColor: AppColors.clay,
        sparklineData: sparklineData['pressure'],
        status: 'healthy',
      ),
      ErrorMetricCard(errorText: metrics?.error),
    ];

    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.xl,
      crossAxisSpacing: AppSpacing.xl,
      childAspectRatio: 0.78,
      children: cards,
    );
  }
}
