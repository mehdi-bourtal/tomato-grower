class WeatherData {
  final double temperature;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final int humidity;
  final int pressure;
  final double windSpeed;
  final int? windDeg;
  final int clouds;
  final int? visibility;
  final String description;
  final String icon;
  final String main;
  final DateTime? sunrise;
  final DateTime? sunset;
  final String? cityName;

  WeatherData({
    required this.temperature,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.pressure,
    required this.windSpeed,
    this.windDeg,
    required this.clouds,
    this.visibility,
    required this.description,
    required this.icon,
    required this.main,
    this.sunrise,
    this.sunset,
    this.cityName,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final mainData = json['main'] as Map<String, dynamic>? ?? {};
    final wind = json['wind'] as Map<String, dynamic>? ?? {};
    final clouds = json['clouds'] as Map<String, dynamic>? ?? {};
    final sys = json['sys'] as Map<String, dynamic>? ?? {};
    final weatherList = json['weather'] as List? ?? [];
    final weather =
        weatherList.isNotEmpty ? weatherList[0] as Map<String, dynamic> : {};

    return WeatherData(
      temperature: _toDouble(mainData['temp']),
      feelsLike: _toDouble(mainData['feels_like']),
      tempMin: _toDouble(mainData['temp_min']),
      tempMax: _toDouble(mainData['temp_max']),
      humidity: _toInt(mainData['humidity']),
      pressure: _toInt(mainData['pressure']),
      windSpeed: _toDouble(wind['speed']),
      windDeg: (wind['deg'] as num?)?.toInt(),
      clouds: _toInt(clouds['all']),
      visibility: (json['visibility'] as num?)?.toInt(),
      description: (weather['description'] as String?) ?? '',
      icon: (weather['icon'] as String?) ?? '01d',
      main: (weather['main'] as String?) ?? '',
      sunrise: sys['sunrise'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (sys['sunrise'] as num).toInt() * 1000)
          : null,
      sunset: sys['sunset'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (sys['sunset'] as num).toInt() * 1000)
          : null,
      cityName: json['name'] as String?,
    );
  }

  String get iconUrl => 'https://openweathermap.org/img/wn/$icon@2x.png';

  String get windDirection {
    if (windDeg == null) return '';
    const directions = [
      'N', 'NNE', 'NE', 'ENE', 'E', 'ESE', 'SE', 'SSE',
      'S', 'SSW', 'SW', 'WSW', 'W', 'WNW', 'NW', 'NNW',
    ];
    final index = ((windDeg! + 11.25) / 22.5).floor() % 16;
    return directions[index];
  }

  static double _toDouble(dynamic v) => (v as num?)?.toDouble() ?? 0.0;
  static int _toInt(dynamic v) => (v as num?)?.toInt() ?? 0;
}
