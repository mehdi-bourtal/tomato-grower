import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../repositories/culture_repository.dart';
import '../repositories/processor_repository.dart';
import '../repositories/tomato_repository.dart';
import '../repositories/watering_repository.dart';
import '../repositories/weather_repository.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final supabaseBucketProvider = Provider<String>((ref) {
  return dotenv.env['SUPABASE_BUCKET'] ?? '';
});

final cultureRepositoryProvider = Provider<CultureRepository>((ref) {
  return CultureRepository(ref.watch(supabaseClientProvider));
});

final tomatoRepositoryProvider = Provider<TomatoRepository>((ref) {
  return TomatoRepository(ref.watch(supabaseClientProvider));
});

final processorRepositoryProvider = Provider<ProcessorRepository>((ref) {
  return ProcessorRepository(ref.watch(supabaseClientProvider));
});

final wateringRepositoryProvider = Provider<WateringRepository>((ref) {
  return WateringRepository(ref.watch(supabaseClientProvider));
});

final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  return WeatherRepository();
});
