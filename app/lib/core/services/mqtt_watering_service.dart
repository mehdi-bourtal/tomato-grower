import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

/// Publishes watering commands to HiveMQ Cloud over TLS (port 8883).
///
/// Configure in `.env`:
/// - `HIVEMQ_CLUSTER_URL` — broker hostname (or full URL; host is extracted)
/// - `HIVEMQ_USERNAME`, `HIVEMQ_PASSWORD` — HiveMQ credentials
/// - `HIVEMQ_TOPIC_PREFIX` — full MQTT topic used for publish
///
/// Payload: UTF-8 JSON `{"proc_id":"…","volume":…}` on topic
/// `{HIVEMQ_TOPIC_PREFIX}`. [volumeMl] is mL from `proc_info.watering_volume`;
/// JSON uses `"volume": null` when unknown.
class MqttWateringService {
  MqttServerClient? _client;
  Future<void>? _connecting;

  static String _normalizePassword(String raw) {
    var p = raw.trim();
    if (p.startsWith('PASSWORD=')) {
      p = p.substring('PASSWORD='.length);
    }
    return p;
  }

  static String _brokerHost(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return trimmed;
    if (trimmed.contains('://')) {
      return Uri.parse(trimmed).host;
    }
    return trimmed.split('/').first;
  }

  bool get isConfigured {
    final host = dotenv.env['HIVEMQ_CLUSTER_URL'];
    final user = dotenv.env['HIVEMQ_USERNAME'];
    final pass = dotenv.env['HIVEMQ_PASSWORD'];
    return host != null &&
        host.trim().isNotEmpty &&
        user != null &&
        user.trim().isNotEmpty &&
        pass != null &&
        _normalizePassword(pass).isNotEmpty;
  }

  String _topicForProc(String procId) {
    final topic = dotenv.env['HIVEMQ_TOPIC_PREFIX']?.trim();
    if (topic == null || topic.isEmpty) {
      throw StateError(
        'HIVEMQ_TOPIC_PREFIX is missing in .env. '
        'Set it to the exact topic your subscriber listens to.',
      );
    }
    return topic;
  }

  bool _isConnected() {
    final c = _client;
    if (c == null) return false;
    return c.connectionStatus?.state == MqttConnectionState.connected;
  }

  Future<MqttServerClient> _buildClient({
    required String server,
    required String clientId,
    required int port,
    required bool useWebSocket,
  }) async {
    final client = MqttServerClient.withPort(server, clientId, port);
    client.logging(on: kDebugMode);
    client.keepAlivePeriod = 20; // HiveMQ example default
    client.connectTimeoutPeriod = 15000;
    client.socketTimeout = 15000;
    client.autoReconnect = true;
    // For native MQTT over TCP TLS => secure=true.
    // For WebSocket secure (wss://...) => secure must stay false.
    client.secure = !useWebSocket;
    client.securityContext = SecurityContext.defaultContext;
    client.useWebSocket = useWebSocket;
    // Prefer the default websocket implementation for HiveMQ Cloud.
    // The alternate implementation can throw unhandled socket errors on iOS.
    client.useAlternateWebSocketImplementation = false;
    client.onConnected = () {
      debugPrint(
        'MQTT connected (${useWebSocket ? 'wss' : 'tls'}) to $server:$port',
      );
    };
    client.onDisconnected = () {
      debugPrint(
        'MQTT disconnected (${useWebSocket ? 'wss' : 'tls'}) from $server:$port',
      );
    };
    return client;
  }

  Future<void> _connect() async {
    final hostRaw = dotenv.env['HIVEMQ_CLUSTER_URL']?.trim() ?? '';
    final username = dotenv.env['HIVEMQ_USERNAME']?.trim() ?? '';
    final password = _normalizePassword(dotenv.env['HIVEMQ_PASSWORD'] ?? '');

    if (hostRaw.isEmpty || username.isEmpty || password.isEmpty) {
      throw StateError(
        'HiveMQ is not configured. Set HIVEMQ_CLUSTER_URL, '
        'HIVEMQ_USERNAME, and HIVEMQ_PASSWORD in .env',
      );
    }

    final host = _brokerHost(hostRaw);
    if (host.isEmpty) {
      throw StateError('Invalid HIVEMQ_CLUSTER_URL');
    }

    final clientId =
        'tomato_grower_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1 << 20)}';
    final wsPath = dotenv.env['HIVEMQ_WS_PATH']?.trim() ?? '/mqtt';
    final wsPort = int.tryParse(dotenv.env['HIVEMQ_WS_PORT'] ?? '') ?? 443;
    final wssServer = 'wss://$host${wsPath.startsWith('/') ? wsPath : '/$wsPath'}';

    Object? lastError;
    for (final attempt in <({String server, int port, bool ws})>[
      (server: host, port: 8883, ws: false),
      (server: wssServer, port: wsPort, ws: true),
    ]) {
      try {
        final client = await _buildClient(
          server: attempt.server,
          clientId: '${clientId}_${attempt.ws ? 'wss' : 'tls'}',
          port: attempt.port,
          useWebSocket: attempt.ws,
        );
        debugPrint(
          'MQTT attempting ${attempt.ws ? 'wss' : 'tls'} '
          'to ${attempt.server}:${attempt.port}',
        );
        final status = await client.connect(username, password);
        if (status?.state == MqttConnectionState.connected) {
          _client = client;
          return;
        }
        lastError = StateError(
          'MQTT ${attempt.ws ? 'wss' : 'tls'} failed: '
          '${status?.returnCode ?? status?.state}',
        );
        client.disconnect();
      } catch (e) {
        lastError = e;
      }
    }

    throw StateError('MQTT connection failed after TLS+WSS attempts: $lastError');
  }

  Future<void> _ensureConnected() async {
    if (_isConnected()) return;

    if (_connecting != null) {
      await _connecting;
      if (_isConnected()) return;
    }

    _connecting = _connect();
    try {
      await _connecting;
    } finally {
      _connecting = null;
    }

    if (!_isConnected()) {
      throw StateError('MQTT not connected after connect attempt');
    }
  }

  /// Publishes a water command (JSON, UTF-8) for the given processor.
  Future<void> publishWaterCommand(
    String procId, {
    int? volumeMl,
  }) async {
    if (procId.isEmpty) {
      throw ArgumentError('procId must not be empty');
    }

    await _ensureConnected();

    final topic = _topicForProc(procId);
    final payload = jsonEncode({
      'proc_id': procId,
      'volume': volumeMl,
    });
    if (kDebugMode) {
      debugPrint('MQTT publish topic=$topic payload=$payload');
    }
    final builder = MqttClientPayloadBuilder()..addUTF8String(payload);

    final buf = builder.payload;
    if (buf == null) {
      throw StateError('MQTT payload build failed');
    }

    _client!.publishMessage(topic, MqttQos.atLeastOnce, buf);
  }

  void disconnect() {
    _client?.disconnect();
    _client = null;
  }
}
