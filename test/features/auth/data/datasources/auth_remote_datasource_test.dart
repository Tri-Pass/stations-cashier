import 'package:cashier/core/constants/api_endpoints.dart';
import 'package:cashier/core/network/api_client.dart';
import 'package:cashier/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient apiClient;
  late AuthRemoteDataSource dataSource;

  setUp(() {
    apiClient = MockApiClient();
    dataSource = AuthRemoteDataSource(apiClient);
    when(() => apiClient.post(any(), any()))
        .thenAnswer((_) async => <String, dynamic>{});
    when(() => apiClient.post(any(), any(), auth: any(named: 'auth')))
        .thenAnswer((_) async => <String, dynamic>{});
    when(() => apiClient.get(any()))
        .thenAnswer((_) async => <String, dynamic>{});
  });

  group('login', () {
    test('calls post to login endpoint with credentials and auth:false',
        () async {
      final response = {'token': 'tok', 'cashier': {}};
      when(() => apiClient.post(any(), any(), auth: any(named: 'auth')))
          .thenAnswer((_) async => response);

      final result = await dataSource.login('0600', 'pass');

      expect(result, response);
      final captured = verify(
        () => apiClient.post(
          captureAny(),
          captureAny(),
          auth: captureAny(named: 'auth'),
        ),
      ).captured;
      expect(captured[0], ApiEndpoints.login);
      expect((captured[1] as Map)['phone'], '0600');
      expect((captured[1] as Map)['password'], 'pass');
      expect(captured[2], isFalse);
    });
  });

  group('getProfile', () {
    test('calls get on me endpoint', () async {
      final response = {'_id': 'a1', 'name': 'Hassan'};
      when(() => apiClient.get(any())).thenAnswer((_) async => response);

      final result = await dataSource.getProfile();

      expect(result, response);
      verify(() => apiClient.get(ApiEndpoints.me)).called(1);
    });
  });

  group('logout', () {
    test('calls post to logout endpoint', () async {
      when(() => apiClient.post(any(), any())).thenAnswer((_) async => {});

      await dataSource.logout();

      verify(() => apiClient.post(ApiEndpoints.logout, any())).called(1);
    });
  });
}
