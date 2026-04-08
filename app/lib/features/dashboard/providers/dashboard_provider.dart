import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/culture_info.dart';
import '../../../data/models/processor_info.dart';
import '../../../data/models/tomato_status.dart';
import '../../../data/models/watering_event.dart';
import '../../../data/models/weather_data.dart';
import '../../../core/utils/unit_conversion.dart';
import '../../../data/providers/refresh_provider.dart';
import '../../../data/providers/supabase_provider.dart';

final processorsProvider = FutureProvider<List<ProcessorInfo>>((ref) async {
  ref.watch(refreshTriggerProvider);
  final repo = ref.watch(processorRepositoryProvider);
  return repo.fetchAll();
});

final selectedProcessorProvider = StateProvider<ProcessorInfo?>((ref) => null);

final latestMetricsProvider =
    FutureProvider.family<CultureInfo?, String>((ref, procId) async {
  ref.watch(refreshTriggerProvider);
  final repo = ref.watch(cultureRepositoryProvider);
  return repo.fetchLatest(procId);
});

final latestTomatoStatusProvider =
    FutureProvider.family<TomatoStatus?, String>((ref, procId) async {
  ref.watch(refreshTriggerProvider);
  final repo = ref.watch(tomatoRepositoryProvider);
  return repo.fetchLatest(procId);
});

final ripeAlertTomatoStatusProvider =
    FutureProvider.family<TomatoStatus?, String>((ref, procId) async {
  ref.watch(refreshTriggerProvider);
  final repo = ref.watch(tomatoRepositoryProvider);
  final latestRipe = await repo.fetchLatestRipe(procId);
  if (latestRipe != null && (latestRipe.ripeTomatos ?? 0) > 0) {
    return latestRipe;
  }

  // Fallback for unexpected backend/filter behavior.
  final latest = await repo.fetchLatest(procId);
  if (latest != null && (latest.ripeTomatos ?? 0) > 0) {
    return latest;
  }

  return null;
});

final recentPhotosProvider =
    FutureProvider.family<List<TomatoStatus>, String>((ref, procId) async {
  ref.watch(refreshTriggerProvider);
  final repo = ref.watch(tomatoRepositoryProvider);
  return repo.fetchRecent(procId, limit: 5);
});

final sparklineDataProvider =
    FutureProvider.family<Map<String, List<double>>, String>(
        (ref, procId) async {
  ref.watch(refreshTriggerProvider);
  final repo = ref.watch(cultureRepositoryProvider);
  final data = await repo.fetchLast24h(procId);

  final result = <String, List<double>>{
    'temperature': [],
    'humidity_int': [],
    'humidity_ext': [],
    'luminosity': [],
    'pressure': [],
  };

  for (final entry in data) {
    if (entry.temperature != null) {
      result['temperature']!.add(entry.temperature!);
    }
    if (entry.humidityInt != null) {
      result['humidity_int']!.add(entry.humidityInt!);
    }
    if (entry.humidityExt != null) {
      result['humidity_ext']!.add(entry.humidityExt!);
    }
    if (entry.luminosity != null) {
      result['luminosity']!.add(entry.luminosity!.toDouble());
    }
    if (entry.pressure != null) {
      result['pressure']!.add(UnitConversion.pressureToHpa(entry.pressure!));
    }
  }

  return result;
});

final recentWateringsProvider =
    FutureProvider.family<List<WateringEvent>, String>((ref, procId) async {
  ref.watch(refreshTriggerProvider);
  final repo = ref.watch(wateringRepositoryProvider);
  return repo.fetchRecent(procId, limit: 5);
});

final latestWateringProvider =
    FutureProvider.family<WateringEvent?, String>((ref, procId) async {
  ref.watch(refreshTriggerProvider);
  final repo = ref.watch(wateringRepositoryProvider);
  return repo.fetchLatest(procId);
});

final weatherProvider =
    FutureProvider.family<WeatherData?, String>((ref, procId) async {
  ref.watch(refreshTriggerProvider);
  final processorRepo = ref.watch(processorRepositoryProvider);
  final weatherRepo = ref.watch(weatherRepositoryProvider);

  final proc = await processorRepo.fetchById(procId);
  if (proc == null || proc.latitude == null || proc.longitude == null) {
    return null;
  }

  return weatherRepo.fetchWeather(
    lat: proc.latitude!,
    lon: proc.longitude!,
  );
});

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);

final temperatureUnitProvider = StateProvider<bool>((ref) => true);

final refreshIntervalProvider =
    StateProvider<Duration>((ref) => const Duration(minutes: 10));

final notificationsEnabledProvider = StateProvider<bool>((ref) => true);
