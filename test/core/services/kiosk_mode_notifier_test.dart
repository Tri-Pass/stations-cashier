import 'package:cashier/core/services/kiosk_mode_notifier.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const kioskChannel = MethodChannel('courtier/kiosk');
  final List<String> calls = [];

  void setChannelHandler(Future<dynamic> Function(MethodCall)? handler) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(kioskChannel, handler);
  }

  setUp(() {
    calls.clear();
    setChannelHandler((call) async {
      calls.add(call.method);
      return 'OK';
    });
  });

  tearDown(() {
    setChannelHandler(null);
  });

  group('KioskModeNotifier.init', () {
    test('defaults to true and calls startKioskMode when no saved value',
        () async {
      SharedPreferences.setMockInitialValues({});
      final notifier = KioskModeNotifier();

      await notifier.init();

      expect(notifier.value, isFalse);
      expect(calls, ['stopKioskMode']);
    });

    test('loads persisted true and calls startKioskMode', () async {
      SharedPreferences.setMockInitialValues({'kiosk_mode': true});
      final notifier = KioskModeNotifier();

      await notifier.init();

      expect(notifier.value, isTrue);
      expect(calls, contains('startKioskMode'));
    });

    test('loads persisted false and calls stopKioskMode', () async {
      SharedPreferences.setMockInitialValues({'kiosk_mode': false});
      final notifier = KioskModeNotifier();

      await notifier.init();

      expect(notifier.value, isFalse);
      expect(calls, ['stopKioskMode']);
    });
  });

  group('KioskModeNotifier.setKioskMode', () {
    test('enables kiosk: value=true, persisted=true, startKioskMode called',
        () async {
      SharedPreferences.setMockInitialValues({'kiosk_mode': false});
      final notifier = KioskModeNotifier();
      await notifier.init();
      calls.clear();

      await notifier.setKioskMode(true);

      expect(notifier.value, isTrue);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('kiosk_mode'), isTrue);
      expect(calls, ['startKioskMode']);
    });

    test('disables kiosk: value=false, persisted=false, stopKioskMode called',
        () async {
      SharedPreferences.setMockInitialValues({'kiosk_mode': true});
      final notifier = KioskModeNotifier();
      await notifier.init();
      calls.clear();

      await notifier.setKioskMode(false);

      expect(notifier.value, isFalse);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('kiosk_mode'), isFalse);
      expect(calls, ['stopKioskMode']);
    });

    test('notifies listeners when enabled', () async {
      SharedPreferences.setMockInitialValues({'kiosk_mode': false});
      final notifier = KioskModeNotifier();
      await notifier.init();

      final received = <bool>[];
      notifier.addListener(() => received.add(notifier.value));

      await notifier.setKioskMode(true);

      expect(received, [true]);
    });

    test('notifies listeners when disabled', () async {
      SharedPreferences.setMockInitialValues({'kiosk_mode': true});
      final notifier = KioskModeNotifier();
      await notifier.init();

      final received = <bool>[];
      notifier.addListener(() => received.add(notifier.value));

      await notifier.setKioskMode(false);

      expect(received, [false]);
    });

    test('successive toggles persist correctly', () async {
      SharedPreferences.setMockInitialValues({});
      final notifier = KioskModeNotifier();
      await notifier.init();
      expect(notifier.value, isFalse);

      await notifier.setKioskMode(false);
      expect(notifier.value, isFalse);

      await notifier.setKioskMode(true);
      expect(notifier.value, isTrue);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('kiosk_mode'), isTrue);
    });

    test('each call invokes the platform channel independently', () async {
      SharedPreferences.setMockInitialValues({});
      final notifier = KioskModeNotifier();
      await notifier.init();
      calls.clear();

      await notifier.setKioskMode(false);
      await notifier.setKioskMode(false);

      expect(calls, ['stopKioskMode', 'stopKioskMode']);
    });
  });

  group('KioskModeNotifier - platform channel error handling', () {
    setUp(() {
      setChannelHandler((_) async =>
          throw PlatformException(code: 'KIOSK_ERROR', message: 'unsupported'));
    });

    test('init does not throw when platform fails; value still reflects prefs',
        () async {
      SharedPreferences.setMockInitialValues({});
      final notifier = KioskModeNotifier();

      await expectLater(notifier.init(), completes);
      expect(notifier.value, isFalse);
    });

    test('init with false in prefs does not throw; value reflects prefs',
        () async {
      SharedPreferences.setMockInitialValues({'kiosk_mode': false});
      final notifier = KioskModeNotifier();

      await expectLater(notifier.init(), completes);
      expect(notifier.value, isFalse);
    });

    test('setKioskMode does not throw when platform fails; value still updated',
        () async {
      SharedPreferences.setMockInitialValues({});
      final notifier = KioskModeNotifier();
      await notifier.init();

      await expectLater(notifier.setKioskMode(false), completes);
      expect(notifier.value, isFalse);
    });

    test('setKioskMode persists despite platform failure', () async {
      SharedPreferences.setMockInitialValues({});
      final notifier = KioskModeNotifier();
      await notifier.init();

      await notifier.setKioskMode(false);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('kiosk_mode'), isFalse);
    });
  });
}
