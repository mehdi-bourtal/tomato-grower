import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/weather_data.dart';

class WeatherRepository {
  static const _baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  Future<WeatherData?> fetchWeather({
    required String lat,
    required String lon,
  }) async {
    final apiKey = dotenv.env['OPENWEATHER_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      debugPrint('WeatherRepository: OPENWEATHER_API_KEY not set');
      return null;
    }

    final latVal = double.tryParse(lat);
    final lonVal = double.tryParse(lon);
    if (latVal == null || lonVal == null || !latVal.isFinite || !lonVal.isFinite) {
      debugPrint('WeatherRepository: Invalid coordinates lat=$lat lon=$lon');
      return null;
    }

    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'lat': lat,
      'lon': lon,
      'appid': apiKey,
      'units': 'metric',
      'lang': 'en',
    });

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return WeatherData.fromJson(json);
      } else {
        debugPrint(
            'WeatherRepository: HTTP ${response.statusCode} – ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('WeatherRepository.fetchWeather error: $e');
      return null;
    }
  }
}
