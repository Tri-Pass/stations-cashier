import 'package:cashier/core/constants/api_endpoints.dart';
import 'package:cashier/core/network/api_client.dart';
import 'package:cashier/features/drivers/data/datasources/driver_remote_datasource.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient apiClient;
  late DriverRemoteDataSource dataSource;

  final driverJson = {
    '_id': 'd1',
    'name': 'Ahmed',
    'taxiNumber': 'T1',
    'phone': '0600',
    'destination': 'Rabat',
    'seatsTotal': 6,
    'alreadyQueued': false,
  };

  setUp(() {
    apiClient = MockApiClient();
    dataSource = DriverRemoteDataSource(apiClient);
    when(() => apiClient.get(any())).thenAnswer((_) async => driverJson);
    when(() => apiClient.post(any(), any())).thenAnswer((_) async => {});
  });

  group('lookupByNfc', () {
    test('calls correct endpoint and returns NfcDriverInfo', () async {
      when(() => apiClient.get(ApiEndpoints.driverByNfc('tag-001')))
          .thenAnswer((_) async => driverJson);

      final result = await dataSource.lookupByNfc('tag-001');

      expect(result.id, 'd1');
      expect(result.name, 'Ahmed');
      expect(result.seatsTotal, 6);
      verify(() => apiClient.get(ApiEndpoints.driverByNfc('tag-001'))).called(1);
    });

    test('parses alreadyQueued flag', () async {
      when(() => apiClient.get(any())).thenAnswer((_) async =>
          {...driverJson, 'alreadyQueued': true});

      final result = await dataSource.lookupByNfc('tag-001');

      expect(result.alreadyQueued, isTrue);
    });
  });

  group('enqueue', () {
    test('posts to queue endpoint with driverId and lineId', () async {
      await dataSource.enqueue('d1', 'l1');

      verify(() => apiClient.post(
            ApiEndpoints.queue,
            any(
              that: predicate<Map<String, dynamic>>(
                (m) => m['driverId'] == 'd1' && m['lineId'] == 'l1',
              ),
            ),
          )).called(1);
    });
  });
}
