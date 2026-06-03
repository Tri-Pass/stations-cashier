import 'package:cashier/core/storage/local_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late LocalStorage storage;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    storage = LocalStorage();
  });

  group('token', () {
    test('getToken returns null when nothing saved', () async {
      expect(await storage.getToken(), isNull);
    });

    test('saveToken then getToken returns the saved value', () async {
      await storage.saveToken('my_jwt_token');
      expect(await storage.getToken(), 'my_jwt_token');
    });

    test('saveToken overwrites previous token', () async {
      await storage.saveToken('old_token');
      await storage.saveToken('new_token');
      expect(await storage.getToken(), 'new_token');
    });

    test('hasToken returns false when no token stored', () async {
      expect(await storage.hasToken(), isFalse);
    });

    test('hasToken returns true after saving a non-empty token', () async {
      await storage.saveToken('tok123');
      expect(await storage.hasToken(), isTrue);
    });
  });

  group('stationId', () {
    test('getStationId returns null initially', () async {
      expect(await storage.getStationId(), isNull);
    });

    test('saveStationId then getStationId returns the saved value', () async {
      await storage.saveStationId('station_abc');
      expect(await storage.getStationId(), 'station_abc');
    });

    test('saveStationId overwrites previous value', () async {
      await storage.saveStationId('s1');
      await storage.saveStationId('s2');
      expect(await storage.getStationId(), 's2');
    });
  });

  group('clear', () {
    test('clear removes both token and stationId', () async {
      await storage.saveToken('tok');
      await storage.saveStationId('s1');
      await storage.clear();
      expect(await storage.getToken(), isNull);
      expect(await storage.getStationId(), isNull);
    });

    test('hasToken returns false after clear', () async {
      await storage.saveToken('tok');
      await storage.clear();
      expect(await storage.hasToken(), isFalse);
    });
  });
}
