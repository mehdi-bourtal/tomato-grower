import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final refreshTriggerProvider = StateProvider<int>((ref) => 0);

class RefreshManager with WidgetsBindingObserver {
  final WidgetRef _ref;
  Timer? _timer;
  Duration _interval;

  RefreshManager(this._ref, {Duration interval = const Duration(minutes: 10)})
      : _interval = interval;

  void start() {
    WidgetsBinding.instance.addObserver(this);
    _startTimer();
  }

  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
  }

  void updateInterval(Duration interval) {
    _interval = interval;
    _timer?.cancel();
    _startTimer();
  }

  void triggerRefresh() {
    _ref.read(refreshTriggerProvider.notifier).update((s) => s + 1);
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(_interval, (_) => triggerRefresh());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _timer?.cancel();
    } else if (state == AppLifecycleState.resumed) {
      triggerRefresh();
      _startTimer();
    }
  }
}
