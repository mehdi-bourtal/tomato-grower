import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/supabase_tables.dart';
import '../../core/utils/unit_conversion.dart';
import '../models/watering_event.dart';

class WateringRepository {
  final SupabaseClient _client;

  WateringRepository(this._client);

  Future<List<WateringEvent>> fetchRecent(String procId, {int limit = 10}) async {
    try {
      final res = await _client
          .from(SupabaseTables.watering)
          .select()
          .eq('proc_id', procId)
          .order('date', ascending: false)
          .limit(limit);
      return (res as List).map((e) => WateringEvent.fromJson(e)).toList();
    } catch (e) {
      debugPrint('WateringRepository.fetchRecent error: $e');
      throw AppException('Failed to fetch recent waterings: $e');
    }
  }

  Future<List<WateringEvent>> fetchByDateRange(
    String procId,
    DateTime from,
    DateTime to,
  ) async {
    try {
      final res = await _client
          .from(SupabaseTables.watering)
          .select()
          .eq('proc_id', procId)
          .gte('date', from.toIso8601String())
          .lte('date', to.toIso8601String())
          .order('date', ascending: true);
      return (res as List).map((e) => WateringEvent.fromJson(e)).toList();
    } catch (e) {
      debugPrint('WateringRepository.fetchByDateRange error: $e');
      throw AppException('Failed to fetch watering history: $e');
    }
  }

  Future<WateringEvent?> fetchLatest(String procId) async {
    try {
      final res = await _client
          .from(SupabaseTables.watering)
          .select()
          .eq('proc_id', procId)
          .order('date', ascending: false)
          .limit(1)
          .maybeSingle();
      if (res == null) return null;
      return WateringEvent.fromJson(res);
    } catch (e) {
      debugPrint('WateringRepository.fetchLatest error: $e');
      throw AppException('Failed to fetch latest watering: $e');
    }
  }
}
