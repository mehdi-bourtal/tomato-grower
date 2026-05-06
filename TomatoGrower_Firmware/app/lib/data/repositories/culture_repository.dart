import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/supabase_tables.dart';
import '../../core/utils/unit_conversion.dart';
import '../models/culture_info.dart';

class CultureRepository {
  final SupabaseClient _client;

  CultureRepository(this._client);

  Future<CultureInfo?> fetchLatest(String procId) async {
    try {
      final res = await _client
          .from(SupabaseTables.cultureInfo)
          .select()
          .eq('proc_id', procId)
          .order('date', ascending: false)
          .limit(1)
          .maybeSingle();
      if (res == null) return null;
      return CultureInfo.fromJson(res);
    } catch (e) {
      debugPrint('CultureRepository.fetchLatest error: $e');
      throw AppException('Failed to fetch latest metrics: $e');
    }
  }

  Future<List<CultureInfo>> fetchHistory(
    String procId,
    DateTime from,
    DateTime to,
  ) async {
    try {
      final res = await _client
          .from(SupabaseTables.cultureInfo)
          .select()
          .eq('proc_id', procId)
          .gte('date', from.toIso8601String())
          .lte('date', to.toIso8601String())
          .order('date', ascending: true);
      return (res as List).map((e) => CultureInfo.fromJson(e)).toList();
    } catch (e) {
      debugPrint('CultureRepository.fetchHistory error: $e');
      throw AppException('Failed to fetch history: $e');
    }
  }

  Future<List<CultureInfo>> fetchLast24h(String procId) async {
    try {
      final since = DateTime.now().subtract(const Duration(hours: 24));
      final res = await _client
          .from(SupabaseTables.cultureInfo)
          .select()
          .eq('proc_id', procId)
          .gte('date', since.toIso8601String())
          .order('date', ascending: true);
      return (res as List).map((e) => CultureInfo.fromJson(e)).toList();
    } catch (e) {
      debugPrint('CultureRepository.fetchLast24h error: $e');
      throw AppException('Failed to fetch 24h data: $e');
    }
  }

  Future<List<CultureInfo>> fetchRecentForProcessor(
    String procId, {
    int limit = 5,
  }) async {
    try {
      final res = await _client
          .from(SupabaseTables.cultureInfo)
          .select()
          .eq('proc_id', procId)
          .order('date', ascending: false)
          .limit(limit);
      return (res as List).map((e) => CultureInfo.fromJson(e)).toList();
    } catch (e) {
      debugPrint('CultureRepository.fetchRecentForProcessor error: $e');
      throw AppException('Failed to fetch recent metrics: $e');
    }
  }
}
