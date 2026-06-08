import 'package:cashier/core/constants/api_endpoints.dart';
import 'package:cashier/core/network/api_client.dart';
import 'package:cashier/features/lines/data/datasources/lines_remote_datasource.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient apiClient;
  late LinesRemoteDataSource dataSource;

  setUp(() {
    apiClient = MockApiClient();
    dataSource = LinesRemoteDataSource(apiClient);
    when(() => apiClient.get(any())).thenAnswer((_) async => <dynamic>[]);
  });

  group('getLines', () {
    test('calls correct endpoint and returns list', () async {
      final lines = [
        {'_id': 'l1', 'origin': 'Rabat', 'destination': 'Casa', 'price': 50.0},
      ];
      when(() => apiClient.get(ApiEndpoints.lines('s1')))
          .thenAnswer((_) async => lines);

      final result = await dataSource.getLines('s1');

      expect(result, lines);
      verify(() => apiClient.get(ApiEndpoints.lines('s1'))).called(1);
    });

    test('returns empty list when no lines', () async {
      when(() => apiClient.get(any())).thenAnswer((_) async => <dynamic>[]);

      final result = await dataSource.getLines('s1');

      expect(result, isEmpty);
    });
  });

  group('getLineQueue', () {
    test('calls correct endpoint and returns list', () async {
      final queue = [
        {'_id': 't1', 'plateNumber': 'ABC-123', 'driver': {}},
      ];
      when(() => apiClient.get(ApiEndpoints.lineQueue('s1', 'l1')))
          .thenAnswer((_) async => queue);

      final result = await dataSource.getLineQueue('s1', 'l1');

      expect(result, queue);
      verify(() => apiClient.get(ApiEndpoints.lineQueue('s1', 'l1'))).called(1);
    });

    test('returns empty list when queue is empty', () async {
      when(() => apiClient.get(any())).thenAnswer((_) async => <dynamic>[]);

      final result = await dataSource.getLineQueue('s1', 'l1');

      expect(result, isEmpty);
    });
  });
}
