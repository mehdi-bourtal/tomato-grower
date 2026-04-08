import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:workmanager/workmanager.dart';
import '../constants/supabase_tables.dart';
import '../../data/models/processor_info.dart';
import '../../data/models/tomato_status.dart';
import 'notification_service.dart';

const kRipeTomatoCheckTask = 'com.tomatogrower.ripeTomatoCheck';
const kNotificationsEnabledKey = 'notifications_enabled';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    try {
      if (taskName == kRipeTomatoCheckTask || taskName == Workmanager.iOSBackgroundTask) {
        await _checkRipeTomatoes();
      }
    } catch (e) {
      debugPrint('Background task error: $e');
    }
    return true;
  });
}

Future<void> _checkRipeTomatoes() async {
  final prefs = await SharedPreferences.getInstance();
  final enabled = prefs.getBool(kNotificationsEnabledKey) ?? true;
  if (!enabled) return;

  await dotenv.load(fileName: '.env');

  final url = dotenv.env['SUPABASE_URL'];
  final key = dotenv.env['SUPABASE_SERVICE_KEY'];
  if (url == null || url.isEmpty || key == null || key.isEmpty) {
    debugPrint('Background task: missing Supabase credentials');
    return;
  }

  await Supabase.initialize(url: url, anonKey: key);
  final client = Supabase.instance.client;

  await NotificationService.initialize();

  // Fetch all processors
  final procRows = await client.from(SupabaseTables.procInfo).select();
  final processors =
      (procRows as List).map((e) => ProcessorInfo.fromJson(e)).toList();

  if (processors.isEmpty) return;

  int notifId = 0;

  for (final proc in processors) {
    // Fetch the latest tomato status for this processor
    final statusRow = await client
        .from(SupabaseTables.tomatosStatus)
        .select()
        .eq('proc_id', proc.procId)
        .order('date', ascending: false)
        .limit(1)
        .maybeSingle();

    if (statusRow == null) continue;

    final status = TomatoStatus.fromJson(statusRow);
    final ripe = status.ripeTomatos;

    if (ripe != null && ripe > 0) {
      await NotificationService.showRipeTomatoNotification(
        id: notifId++,
        processorName: proc.displayName,
        ripeCount: ripe,
      );
    }
  }
}

class BackgroundTaskService {
  /// Registers background work. Periodic scheduling is only supported on Android
  /// by `workmanager` 0.5.x; iOS uses BGTaskScheduler and does not implement
  /// `registerPeriodicTask` (would throw and white-screen the app).
  static Future<void> registerPeriodicTask() async {
    try {
      await Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode: kDebugMode,
      );
    } catch (e, st) {
      debugPrint('Workmanager.initialize failed: $e\n$st');
      return;
    }

    if (defaultTargetPlatform != TargetPlatform.android) {
      debugPrint(
        'Background ripe-tomato checks: periodic WorkManager is Android-only '
        'in this build; iOS needs BGTaskScheduler setup in AppDelegate.',
      );
      return;
    }

    try {
      await Workmanager().registerPeriodicTask(
        kRipeTomatoCheckTask,
        kRipeTomatoCheckTask,
        frequency: const Duration(hours: 24),
        constraints: Constraints(
          networkType: NetworkType.connected,
        ),
        existingWorkPolicy: ExistingWorkPolicy.keep,
        backoffPolicy: BackoffPolicy.exponential,
        backoffPolicyDelay: const Duration(minutes: 15),
      );
    } catch (e, st) {
      debugPrint('Workmanager.registerPeriodicTask failed: $e\n$st');
    }
  }

  static Future<void> cancelAll() async {
    try {
      await Workmanager().cancelAll();
    } catch (e, st) {
      debugPrint('Workmanager.cancelAll failed: $e\n$st');
    }
  }

  static Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kNotificationsEnabledKey, enabled);

    if (enabled) {
      await registerPeriodicTask();
    } else {
      await cancelAll();
    }
  }

  static Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(kNotificationsEnabledKey) ?? true;
  }
}
