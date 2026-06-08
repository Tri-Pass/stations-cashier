import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KioskModeNotifier extends ValueNotifier<bool> {
  static const _key = 'kiosk_mode';
  static const _kioskChannel = MethodChannel('courtier/kiosk');

  KioskModeNotifier() : super(true);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(_key) ?? true;
    value = enabled;
    await _apply(enabled);
  }

  Future<void> setKioskMode(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, enabled);
    value = enabled;
    await _apply(enabled);
  }

  Future<void> _apply(bool kiosk) async {
    if (kiosk) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      try {
        await _kioskChannel.invokeMethod('startKioskMode');
      } catch (_) {}
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      try {
        await _kioskChannel.invokeMethod('stopKioskMode');
      } catch (_) {}
    }
  }
}
