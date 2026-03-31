import '../../data/models/culture_info.dart';

String computeHealthStatus(CultureInfo? metrics) {
  if (metrics == null) return 'inactive';

  if (metrics.error != null && metrics.error!.isNotEmpty) {
    return 'critical';
  }

  bool anyWarning = false;

  if (metrics.temperature != null) {
    if (metrics.temperature! < 10 || metrics.temperature! > 40) {
      anyWarning = true;
    }
  }
  if (metrics.humidityAir != null) {
    if (metrics.humidityAir! < 30 || metrics.humidityAir! > 90) {
      anyWarning = true;
    }
  }
  if (metrics.humidityGround != null) {
    if (metrics.humidityGround! < 20 || metrics.humidityGround! > 80) {
      anyWarning = true;
    }
  }

  return anyWarning ? 'warning' : 'healthy';
}

String statusMessage(String status) {
  switch (status) {
    case 'healthy':
      return 'Your tomatoes are thriving!';
    case 'warning':
      return 'Needs attention';
    case 'critical':
      return 'Urgent care needed!';
    default:
      return 'Waiting for data…';
  }
}
