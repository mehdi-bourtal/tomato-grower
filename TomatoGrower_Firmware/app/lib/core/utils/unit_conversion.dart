import 'package:intl/intl.dart';

class UnitConversion {
  UnitConversion._();

  static double celsiusToFahrenheit(double c) => c * 9 / 5 + 32;
  static double fahrenheitToCelsius(double f) => (f - 32) * 5 / 9;

  /// Converts raw `culture_info.pressure` (float4 from Supabase) to hectopascals
  /// for display. Supports:
  /// - **bar** (~0.9–1.2): e.g. `1.025` → 1025 hPa
  /// - **Pa** (large integers): e.g. `101325` → ~1013 hPa
  /// - **hPa** already: e.g. `1013` → unchanged
  static double pressureToHpa(double value) {
    if (value > 20000) return value / 100.0;
    if (value >= 300 && value <= 1300) return value;
    if (value > 0 && value < 2.5) return value * 1000.0;
    return value;
  }

  static final _intFmt = NumberFormat('#,##0');
  static final _decFmt = NumberFormat('#,##0.0');

  static String formatTemperature(double? value, {bool celsius = true}) {
    if (value == null) return '—';
    final v = celsius ? value : celsiusToFahrenheit(value);
    return _decFmt.format(v);
  }

  static String formatHumidity(double? value) {
    if (value == null) return '—';
    return _decFmt.format(value);
  }

  static String formatInt(int? value) {
    if (value == null) return '—';
    return _intFmt.format(value);
  }

  static String formatPressure(double? value) {
    if (value == null) return '—';
    return _decFmt.format(pressureToHpa(value));
  }
}

class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}
