import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/tomato_status.dart';
import '../../../data/providers/refresh_provider.dart';
import '../../../data/providers/supabase_provider.dart';
import '../../dashboard/providers/dashboard_provider.dart';

final allPhotosProvider = FutureProvider<List<TomatoStatus>>((ref) async {
  ref.watch(refreshTriggerProvider);
  final proc = ref.watch(selectedProcessorProvider);
  if (proc == null) return [];
  final repo = ref.watch(tomatoRepositoryProvider);
  return repo.fetchAll(proc.procId);
});
