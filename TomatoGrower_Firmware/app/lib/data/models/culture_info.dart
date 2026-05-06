class CultureInfo {
  final DateTime date;
  final String procId;
  final double? temperature;
  final double? humidityInt;
  final double? humidityExt;
  final int? luminosity;
  final double? pressure;
  final String? error;

  CultureInfo({
    required this.date,
    required this.procId,
    this.temperature,
    this.humidityInt,
    this.humidityExt,
    this.luminosity,
    this.pressure,
    this.error,
  });

  factory CultureInfo.fromJson(Map<String, dynamic> json) {
    return CultureInfo(
      date: DateTime.parse(json['date'] as String),
      procId: json['proc_id'] as String,
      temperature: (json['temperature'] as num?)?.toDouble(),
      humidityInt: (json['humidity_int'] as num?)?.toDouble(),
      humidityExt: (json['humidity_ext'] as num?)?.toDouble(),
      luminosity: (json['luminosity'] as num?)?.toInt(),
      pressure: (json['pressure'] as num?)?.toDouble(),
      error: json['error'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'proc_id': procId,
        'temperature': temperature,
        'humidity_int': humidityInt,
        'humidity_ext': humidityExt,
        'luminosity': luminosity,
        'pressure': pressure,
        'error': error,
      };
}
