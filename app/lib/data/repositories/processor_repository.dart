import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/supabase_tables.dart';
import '../../core/utils/unit_conversion.dart';
import '../models/processor_info.dart';

class ProcessorRepository {
  final SupabaseClient _client;

  ProcessorRepository(this._client);

  Future<List<ProcessorInfo>> fetchAll() async {
    try {
      final res = await _client.from(SupabaseTables.procInfo).select();
      return (res as List).map((e) => ProcessorInfo.fromJson(e)).toList();
    } catch (e) {
      debugPrint('ProcessorRepository.fetchAll error: $e');
      throw AppException('Failed to fetch processors: $e');
    }
  }

  Future<ProcessorInfo?> fetchById(String procId) async {
    try {
      final res = await _client
          .from(SupabaseTables.procInfo)
          .select()
          .eq('proc_id', procId)
          .maybeSingle();
      if (res == null) return null;
      return ProcessorInfo.fromJson(res);
    } catch (e) {
      debugPrint('ProcessorRepository.fetchById error: $e');
      throw AppException('Failed to fetch processor: $e');
    }
  }
}
