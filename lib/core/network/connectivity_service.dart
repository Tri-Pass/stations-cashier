import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum ConnectivityState { checking, online, offline }

class ConnectivityService {
  // Two DNS servers probed in parallel; either succeeding means we're online.
  // Using two targets avoids false-offline when 8.8.8.8 is blocked or slow.
  static const _probeTargets = [('8.8.8.8', 53), ('1.1.1.1', 53)];
  static const _probeTimeout  = Duration(seconds: 4);
  static const _raceTimeout   = Duration(seconds: 5);

  static const _onlineInterval  = Duration(seconds: 15);
  static const _offlineInterval = Duration(seconds: 4);

  static const _wifiChannel = MethodChannel('courtier/wifi');

  final _state = ValueNotifier<ConnectivityState>(ConnectivityState.checking);
  ValueNotifier<ConnectivityState> get state => _state;

  Timer? _timer;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _checking = false;

  ConnectivityService() {
    _init();
  }

  static Future<bool> _defaultSocketCheck() async {
    try {
      return await Future.any(
        _probeTargets.map((t) async {
          final socket = await Socket.connect(t.$1, t.$2, timeout: _probeTimeout);
          socket.destroy();
          return true;
        }),
      ).timeout(_raceTimeout, onTimeout: () => false);
    } catch (_) {
      return false;
    }
  }

  Future<void> _init() async {
    _subscription =
        Connectivity().onConnectivityChanged.listen(_onConnectivityChanged);
    await _check();
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    _timer?.cancel();
    if (results.isEmpty || results.every((r) => r == ConnectivityResult.none)) {
      _state.value = ConnectivityState.offline;
      _scheduleNext();
    } else {
      // Adapter is up — verify actual internet with a socket probe.
      _check();
    }
  }

  Future<void> recheck() async {
    _timer?.cancel();
    _checking = false;
    await _check();
  }

  /// Disconnects then reconnects the WiFi adapter via a platform channel so
  /// the app can recover without the user touching system settings (kiosk mode).
  Future<void> reconnectWifi() async {
    try {
      await _wifiChannel.invokeMethod<void>('reconnect');
    } catch (_) {
      // Platform may not support it; continue to recheck anyway.
    }
    await Future<void>.delayed(const Duration(seconds: 3));
    await recheck();
  }

  Future<void> _check() async {
    if (_checking) return;
    _checking = true;
    try {
      final online = await _defaultSocketCheck();
      _state.value = online ? ConnectivityState.online : ConnectivityState.offline;
    } finally {
      _checking = false;
      _scheduleNext();
    }
  }

  void _scheduleNext() {
    _timer?.cancel();
    final interval = _state.value == ConnectivityState.online
        ? _onlineInterval
        : _offlineInterval;
    _timer = Timer(interval, _check);
  }

  void dispose() {
    _timer?.cancel();
    _subscription?.cancel();
    _state.dispose();
  }
}
