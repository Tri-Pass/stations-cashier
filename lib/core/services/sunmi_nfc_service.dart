import 'dart:async';
import 'dart:developer';
import 'package:flutter/services.dart';

class SunmiNfcService {
  static const _methodChannel = MethodChannel('courtier/card_methods');
  static const _eventChannel = EventChannel('courtier/card_events');

  static final _controller =
      StreamController<Map<String, dynamic>>.broadcast();
  static bool _initialized = false;
  static int _scanCount = 0;
  static DateTime? _lastCardTime;
  static const _cardDebounce = Duration(milliseconds: 1500);

  // Set to true by any local handler (booking dialog, nfc-link page) so the
  // global app-level listener knows to suppress its own handling.
  static bool localHandlerActive = false;

  static void ensureInitialized() {
    if (_initialized) return;
    _initialized = true;
    _eventChannel.receiveBroadcastStream().listen(
      (event) {
        if (event is Map) {
          final data = Map<String, dynamic>.from(event);
          if (data['event'] == 'CARD_FOUND') {
            final now = DateTime.now();
            if (_lastCardTime != null &&
                now.difference(_lastCardTime!) < _cardDebounce) {
              return;
            }
            _lastCardTime = now;
          }
          _controller.add(data);
        }
      },
      onError: (e) => log('NFC native stream error: $e'),
    );
  }

  static Future<void> startScanning() async {
    _scanCount++;
    if (_scanCount == 1) {
      try {
        await _methodChannel.invokeMethod('startNfcScan');
      } on PlatformException catch (e) {
        log('NFC start error: ${e.message}');
      }
    }
  }

  static Future<void> stopScanning() async {
    if (_scanCount <= 0) return;
    _scanCount--;
    if (_scanCount == 0) {
      try {
        await _methodChannel.invokeMethod('stopNfcScan');
      } on PlatformException catch (e) {
        log('NFC stop error: ${e.message}');
      }
    }
  }

  static Stream<Map<String, dynamic>> allEventsStream() => _controller.stream;

  static Stream<String> cardIdStream() {
    return _controller.stream
        .where((e) => e['event'] == 'CARD_FOUND')
        .map((e) => e['details']?.toString() ?? '');
  }

  static String toLittleEndianDecimal(String hex) {
    final bytes = <String>[];
    for (int i = 0; i < hex.length; i += 2) {
      bytes.add(hex.substring(i, i + 2));
    }
    final reversedHex = bytes.reversed.join();
    return BigInt.parse(reversedHex, radix: 16).toString();
  }
}
