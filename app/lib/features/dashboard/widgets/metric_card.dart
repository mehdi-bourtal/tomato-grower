import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/status_dot.dart';

class MetricCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? value;
  final String unit;
  final Color metricColor;
  final List<double>? sparklineData;
  final String status;

  const MetricCard({
    super.key,
    required this.title,
    required this.icon,
    required this.value,
    required this.unit,
    required this.metricColor,
    this.sparklineData,
    this.status = 'healthy',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.soil800,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.soil600),
        boxShadow: status == 'healthy'
            ? [
                BoxShadow(
                  color: AppColors.leafGreen.withOpacity(0.08),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 24, color: AppColors.leafGreenLight),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.cream,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              StatusDot(status: status),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            value ?? '—',
            style: AppTypography.metricValue.copyWith(color: AppColors.cream),
          ),
          Text(
            unit,
            style: AppTypography.metricUnit.copyWith(color: AppColors.clay),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (sparklineData != null && sparklineData!.length >= 2)
            SizedBox(
              height: 32,
              child: _Sparkline(
                data: sparklineData!,
                color: metricColor,
              ),
            )
          else
            const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _Sparkline extends StatelessWidget {
  final List<double> data;
  final Color color;

  const _Sparkline({required this.data, required this.color});

  @override
  Widget build(BuildContext context) {
    final spots = data
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: const LineTouchData(enabled: false),
        clipData: const FlClipData.all(),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: color,
            barWidth: 1.5,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: color.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }
}

class ErrorMetricCard extends StatelessWidget {
  final String? errorText;

  const ErrorMetricCard({super.key, this.errorText});

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.soil800,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: hasError ? AppColors.tomatoRed.withOpacity(0.5) : AppColors.soil600,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                hasError ? Icons.error_outline : Icons.check_circle_outline,
                size: 24,
                color: hasError ? AppColors.tomatoRed : AppColors.leafGreen,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Status',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.cream,
                  ),
                ),
              ),
              StatusDot(status: hasError ? 'critical' : 'healthy'),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (hasError)
            Text(
              errorText!,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.tomatoRed,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            )
          else
            Text(
              'All clear',
              style: AppTypography.metricValue.copyWith(
                color: AppColors.leafGreen,
              ),
            ),
          const Spacer(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
