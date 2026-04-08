import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/weather_data.dart';

class WeatherCard extends StatelessWidget {
  final WeatherData weather;
  final bool celsius;

  const WeatherCard({
    super.key,
    required this.weather,
    this.celsius = true,
  });

  String _formatTemp(double temp) {
    if (celsius) return '${temp.round()}°C';
    return '${(temp * 9 / 5 + 32).round()}°F';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.soil800,
            AppColors.soil700.withValues(alpha: 0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.soil600),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                PhosphorIconsBold.cloudSun,
                size: 20,
                color: AppColors.sunYellow,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Local Weather',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.cream,
                ),
              ),
              if (weather.cityName != null && weather.cityName!.isNotEmpty) ...[
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    '· ${weather.cityName}',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.clay,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ] else
                const Spacer(),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CachedNetworkImage(
                imageUrl: weather.iconUrl,
                width: 56,
                height: 56,
                errorWidget: (_, __, ___) => const Icon(
                  PhosphorIconsBold.cloudSun,
                  size: 56,
                  color: AppColors.sunYellow,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatTemp(weather.temperature),
                      style: AppTypography.metricValue.copyWith(
                        color: AppColors.cream,
                      ),
                    ),
                    Text(
                      weather.description.isNotEmpty
                          ? '${weather.description[0].toUpperCase()}${weather.description.substring(1)}'
                          : weather.main,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.clay,
                      ),
                    ),
                    Text(
                      'Feels like ${_formatTemp(weather.feelsLike)}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.clay,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${_formatTemp(weather.tempMax)} ↑',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.tomatoOrange,
                    ),
                  ),
                  Text(
                    '${_formatTemp(weather.tempMin)} ↓',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.water,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),
          const Divider(color: AppColors.soil600, height: 1),
          const SizedBox(height: AppSpacing.md),

          Row(
            children: [
              _MiniMetric(
                icon: PhosphorIconsBold.drop,
                iconColor: AppColors.water,
                value: '${weather.humidity}%',
                label: 'Humidity',
              ),
              _MiniMetric(
                icon: PhosphorIconsBold.wind,
                iconColor: AppColors.sprout,
                value:
                    '${weather.windSpeed.toStringAsFixed(1)} m/s',
                label: weather.windDirection.isNotEmpty
                    ? weather.windDirection
                    : 'Wind',
              ),
              _MiniMetric(
                icon: PhosphorIconsBold.cloud,
                iconColor: AppColors.clay,
                value: '${weather.clouds}%',
                label: 'Clouds',
              ),
              _MiniMetric(
                icon: PhosphorIconsBold.gauge,
                iconColor: AppColors.leafGreenLight,
                value: '${weather.pressure}',
                label: 'hPa',
              ),
            ],
          ),

          if (weather.sunrise != null && weather.sunset != null) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  PhosphorIconsBold.sunHorizon,
                  size: 14,
                  color: AppColors.sunYellow,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  _formatTime(weather.sunrise!),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.sunYellow,
                  ),
                ),
                const SizedBox(width: AppSpacing.xl),
                const Icon(
                  PhosphorIconsBold.moonStars,
                  size: 14,
                  color: AppColors.clay,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  _formatTime(weather.sunset!),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.clay,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _MiniMetric extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _MiniMetric({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTypography.labelSmall.copyWith(color: AppColors.cream),
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.clay,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
