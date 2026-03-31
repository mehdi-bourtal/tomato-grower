import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/culture_info.dart';
import '../../../data/models/processor_info.dart';
import '../../../data/models/tomato_status.dart';
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
    'humidity_air': [],
    'humidity_ground': [],
    'luminosity': [],
    'pressure': [],
  };

  for (final entry in data) {
    if (entry.temperature != null) {
      result['temperature']!.add(entry.temperature!);
    }
    if (entry.humidityAir != null) {
      result['humidity_air']!.add(entry.humidityAir!.toDouble());
    }
    if (entry.humidityGround != null) {
      result['humidity_ground']!.add(entry.humidityGround!.toDouble());
    }
    if (entry.luminosity != null) {
      result['luminosity']!.add(entry.luminosity!.toDouble());
    }
    if (entry.pressure != null) {
      result['pressure']!.add(entry.pressure!.toDouble());
    }
  }

  return result;
});

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);

final temperatureUnitProvider = StateProvider<bool>((ref) => true);

final refreshIntervalProvider =
    StateProvider<Duration>((ref) => const Duration(minutes: 10));

final notificationsEnabledProvider = StateProvider<bool>((ref) => true);
