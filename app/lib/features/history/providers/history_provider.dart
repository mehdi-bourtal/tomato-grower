import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/culture_info.dart';
import '../../../data/models/tomato_status.dart';
import '../../../data/providers/refresh_provider.dart';
import '../../../data/providers/supabase_provider.dart';
import '../../dashboard/providers/dashboard_provider.dart';

final dateRangeProvider = StateProvider<DateTimeRange>((ref) {
  final now = DateTime.now();
  return DateTimeRange(
    start: now.subtract(const Duration(days: 7)),
    end: now,
  );
});

final selectedMetricsProvider = StateProvider<Set<String>>((ref) {
  return {'temperature', 'humidity_air', 'humidity_ground', 'luminosity', 'pressure'};
});

final historyDataProvider = FutureProvider<List<CultureInfo>>((ref) async {
  ref.watch(refreshTriggerProvider);
  final proc = ref.watch(selectedProcessorProvider);
  final range = ref.watch(dateRangeProvider);
  if (proc == null) return [];
  final repo = ref.watch(cultureRepositoryProvider);
  return repo.fetchHistory(proc.procId, range.start, range.end);
});

final harvestDataProvider = FutureProvider<List<TomatoStatus>>((ref) async {
  ref.watch(refreshTriggerProvider);
  final proc = ref.watch(selectedProcessorProvider);
  final range = ref.watch(dateRangeProvider);
  if (proc == null) return [];
  final repo = ref.watch(tomatoRepositoryProvider);
  return repo.fetchByDateRange(proc.procId, range.start, range.end);
});
