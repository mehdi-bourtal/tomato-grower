import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/mqtt_watering_service.dart';

final mqttWateringServiceProvider = Provider<MqttWateringService>((ref) {
  final service = MqttWateringService();
  ref.onDispose(service.disconnect);
  return service;
});
