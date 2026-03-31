import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'core/services/background_task_service.dart';
import 'core/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Failed to load .env file: $e');
    runApp(const _ErrorApp(message: 'Failed to load .env configuration file.'));
    return;
  }

  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseKey = dotenv.env['SUPABASE_SERVICE_KEY'];

  if (supabaseUrl == null || supabaseUrl.isEmpty) {
    runApp(const _ErrorApp(message: 'SUPABASE_URL is missing from .env'));
    return;
  }
  if (supabaseKey == null || supabaseKey.isEmpty) {
    runApp(
      const _ErrorApp(message: 'SUPABASE_SERVICE_KEY is missing from .env'),
    );
    return;
  }

  try {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
  } catch (e) {
    debugPrint('Supabase initialization failed: $e');
    runApp(_ErrorApp(message: 'Supabase initialization failed: $e'));
    return;
  }

  await NotificationService.initialize();
  await NotificationService.requestPermission();

  final notificationsEnabled =
      await BackgroundTaskService.getNotificationsEnabled();
  if (notificationsEnabled) {
    await BackgroundTaskService.registerPeriodicTask();
  }

  runApp(
    const ProviderScope(
      child: TomatoGrowerApp(),
    ),
  );
}

class _ErrorApp extends StatelessWidget {
  final String message;

  const _ErrorApp({required this.message});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF0F1A0F),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Color(0xFFE53935)),
                const SizedBox(height: 24),
                const Text(
                  'Startup Error',
                  style: TextStyle(
                    color: Color(0xFFFFF8E1),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: const TextStyle(
                    color: Color(0xFF8D6E63),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
