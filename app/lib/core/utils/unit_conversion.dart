import 'package:intl/intl.dart';

class UnitConversion {
  UnitConversion._();

  static double celsiusToFahrenheit(double c) => c * 9 / 5 + 32;
  static double fahrenheitToCelsius(double f) => (f - 32) * 5 / 9;

  static double paToHpa(int pa) => pa / 100.0;

  static final _intFmt = NumberFormat('#,##0');
  static final _decFmt = NumberFormat('#,##0.0');

  static String formatTemperature(double? value, {bool celsius = true}) {
    if (value == null) return '—';
    final v = celsius ? value : celsiusToFahrenheit(value);
    return _decFmt.format(v);
  }

  static String formatInt(int? value) {
    if (value == null) return '—';
    return _intFmt.format(value);
  }

  static String formatPressure(int? value) {
    if (value == null) return '—';
    return _intFmt.format(value);
  }
}

class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}
