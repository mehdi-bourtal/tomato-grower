class CultureInfo {
  final DateTime date;
  final String procId;
  final double? temperature;
  final int? humidityAir;
  final int? humidityGround;
  final int? luminosity;
  final int? pressure;
  final String? error;

  CultureInfo({
    required this.date,
    required this.procId,
    this.temperature,
    this.humidityAir,
    this.humidityGround,
    this.luminosity,
    this.pressure,
    this.error,
  });

  factory CultureInfo.fromJson(Map<String, dynamic> json) {
    return CultureInfo(
      date: DateTime.parse(json['date'] as String),
      procId: json['proc_id'] as String,
      temperature: (json['temperature'] as num?)?.toDouble(),
      humidityAir: (json['humidity_air'] as num?)?.toInt(),
      humidityGround: (json['humidity_ground'] as num?)?.toInt(),
      luminosity: (json['luminosity'] as num?)?.toInt(),
      pressure: (json['pressure'] as num?)?.toInt(),
      error: json['error'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'proc_id': procId,
        'temperature': temperature,
        'humidity_air': humidityAir,
        'humidity_ground': humidityGround,
        'luminosity': luminosity,
        'pressure': pressure,
        'error': error,
      };
}
