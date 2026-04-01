import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/supabase_tables.dart';
import '../../core/utils/unit_conversion.dart';
import '../models/tomato_status.dart';

class TomatoRepository {
  final SupabaseClient _client;

  TomatoRepository(this._client);

  Future<TomatoStatus?> fetchLatest(String procId) async {
    try {
      final res = await _client
          .from(SupabaseTables.tomatosStatus)
          .select()
          .eq('proc_id', procId)
          .order('date', ascending: false)
          .limit(1)
          .maybeSingle();
      if (res == null) return null;
      return TomatoStatus.fromJson(res);
    } catch (e) {
      debugPrint('TomatoRepository.fetchLatest error: $e');
      throw AppException('Failed to fetch latest tomato status: $e');
    }
  }

  Future<List<TomatoStatus>> fetchAll(String procId) async {
    try {
      final res = await _client
          .from(SupabaseTables.tomatosStatus)
          .select()
          .eq('proc_id', procId)
          .order('date', ascending: false);
      return (res as List).map((e) => TomatoStatus.fromJson(e)).toList();
    } catch (e) {
      debugPrint('TomatoRepository.fetchAll error: $e');
      throw AppException('Failed to fetch tomato statuses: $e');
    }
  }

  Future<List<TomatoStatus>> fetchRecent(String procId, {int limit = 5}) async {
    try {
      final res = await _client
          .from(SupabaseTables.tomatosStatus)
          .select()
          .eq('proc_id', procId)
          .order('date', ascending: false)
          .limit(limit);
      return (res as List).map((e) => TomatoStatus.fromJson(e)).toList();
    } catch (e) {
      debugPrint('TomatoRepository.fetchRecent error: $e');
      throw AppException('Failed to fetch recent photos: $e');
    }
  }

  Future<TomatoStatus?> fetchLatestRipe(String procId) async {
    try {
      final res = await _client
          .from(SupabaseTables.tomatosStatus)
          .select()
          .eq('proc_id', procId)
          .gt('ripe_tomtatos', 0)
          .order('date', ascending: false)
          .limit(1)
          .maybeSingle();
      if (res == null) return null;
      return TomatoStatus.fromJson(res);
    } catch (e) {
      debugPrint('TomatoRepository.fetchLatestRipe error: $e');
      throw AppException('Failed to fetch latest ripe tomato status: $e');
    }
  }

  Future<List<TomatoStatus>> fetchByDateRange(
    String procId,
    DateTime from,
    DateTime to,
  ) async {
    try {
      final res = await _client
          .from(SupabaseTables.tomatosStatus)
          .select()
          .eq('proc_id', procId)
          .gte('date', from.toIso8601String())
          .lte('date', to.toIso8601String())
          .order('date', ascending: true);
      return (res as List).map((e) => TomatoStatus.fromJson(e)).toList();
    } catch (e) {
      debugPrint('TomatoRepository.fetchByDateRange error: $e');
      throw AppException('Failed to fetch harvest data: $e');
    }
  }

  String? getPublicImageUrl(String? urlOrPath) {
    if (urlOrPath == null || urlOrPath.isEmpty) return null;
    if (urlOrPath.startsWith('http')) return urlOrPath;
    final bucket = dotenv.env['SUPABASE_BUCKET'] ?? '';
    if (bucket.isEmpty) return null;
    try {
      return _client.storage.from(bucket).getPublicUrl(urlOrPath);
    } catch (e) {
      debugPrint('TomatoRepository.getPublicImageUrl error: $e');
      return null;
    }
  }

  Future<String?> getSignedImageUrl(String? urlOrPath) async {
    if (urlOrPath == null || urlOrPath.isEmpty) return null;
    final bucket = dotenv.env['SUPABASE_BUCKET'] ?? '';
    if (bucket.isEmpty) return getPublicImageUrl(urlOrPath);
    try {
      final storagePath = _extractStoragePath(urlOrPath, bucket);
      return await _client.storage
          .from(bucket)
          .createSignedUrl(storagePath, 3600);
    } catch (e) {
      debugPrint('TomatoRepository.getSignedImageUrl error: $e');
      return getPublicImageUrl(urlOrPath);
    }
  }

  String _extractStoragePath(String urlOrPath, String bucket) {
    if (!urlOrPath.startsWith('http')) return urlOrPath;
    try {
      final uri = Uri.parse(urlOrPath);
      final path = uri.path;
      final markers = [
        '/storage/v1/object/public/$bucket/',
        '/storage/v1/object/authenticated/$bucket/',
        '/storage/v1/object/sign/$bucket/',
      ];
      for (final marker in markers) {
        final idx = path.indexOf(marker);
        if (idx >= 0) return Uri.decodeComponent(path.substring(idx + marker.length));
      }
    } catch (_) {}
    return urlOrPath;
  }
}
