import 'package:cashier/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:cashier/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:cashier/core/storage/local_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

void main() {
  late MockAuthRemoteDataSource dataSource;
  late LocalStorage storage;
  late AuthRepositoryImpl repo;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    dataSource = MockAuthRemoteDataSource();
    storage = LocalStorage();
    repo = AuthRepositoryImpl(dataSource, storage);
  });

  final loginResponse = {
    'token': 'test_token',
    'cashier': {
      '_id': 'agent-1',
      'name': 'Hassan',
      'phone': '0601020304',
      'taxiNumber': 'T1',
      'plateNumber': 'ABC-123',
      'balance': 100.0,
      'station': {'_id': 's1', 'name': 'Gare'},
    },
  };

  group('login', () {
    test('saves token and returns driver entity', () async {
      when(() => dataSource.login(any(), any()))
          .thenAnswer((_) async => loginResponse);

      final entity = await repo.login('0601020304', 'pass');

      expect(entity.name, 'Hassan');
      expect(entity.phone, '0601020304');
      expect(entity.station?.name, 'Gare');
      expect(await storage.getToken(), 'test_token');
    });

    test('saves station id from cashier model', () async {
      when(() => dataSource.login(any(), any()))
          .thenAnswer((_) async => loginResponse);

      await repo.login('0601020304', 'pass');

      expect(await storage.getStationId(), 's1');
    });

    test('handles cashier without station', () async {
      final responseNoStation = {
        'token': 'tok',
        'cashier': {
          '_id': 'a1',
          'name': 'Test',
          'phone': '0600',
          'taxiNumber': '',
          'plateNumber': '',
          'balance': 0.0,
        },
      };
      when(() => dataSource.login(any(), any()))
          .thenAnswer((_) async => responseNoStation);

      final entity = await repo.login('0600', 'pass');

      expect(entity.station, isNull);
    });
  });

  group('getProfile', () {
    test('returns driver entity from data source', () async {
      when(() => dataSource.getProfile()).thenAnswer((_) async => {
            '_id': 'agent-1',
            'name': 'Hassan',
            'phone': '0601020304',
            'taxiNumber': 'T1',
            'plateNumber': 'ABC-123',
            'balance': 100.0,
          });

      final entity = await repo.getProfile();

      expect(entity.id, 'agent-1');
      expect(entity.name, 'Hassan');
    });
  });

  group('isAuthenticated', () {
    test('returns false when no token saved', () async {
      expect(await repo.isAuthenticated(), isFalse);
    });

    test('returns true when token exists', () async {
      await storage.saveToken('some_token');
      expect(await repo.isAuthenticated(), isTrue);
    });
  });

  group('logout', () {
    test('clears storage even when data source throws', () async {
      when(() => dataSource.logout()).thenThrow(Exception('network error'));
      await storage.saveToken('tok');

      await repo.logout();

      expect(await storage.getToken(), isNull);
    });

    test('clears storage on successful logout', () async {
      when(() => dataSource.logout()).thenAnswer((_) async {});
      await storage.saveToken('tok');

      await repo.logout();

      expect(await storage.getToken(), isNull);
    });
  });

  group('getToken', () {
    test('returns null when no token', () async {
      expect(await repo.getToken(), isNull);
    });

    test('returns saved token', () async {
      await storage.saveToken('my_token');
      expect(await repo.getToken(), 'my_token');
    });
  });
}
