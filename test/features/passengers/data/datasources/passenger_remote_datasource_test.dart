import 'package:cashier/core/constants/api_endpoints.dart';
import 'package:cashier/core/network/api_client.dart';
import 'package:cashier/features/passengers/data/datasources/passenger_remote_datasource.dart';
import 'package:cashier/features/passengers/domain/entities/passenger_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient apiClient;
  late PassengerRemoteDataSource dataSource;

  final passengerJson = {
    '_id': 'p1',
    'name': 'Ali',
    'phone': '0600',
    'balance': 100.0,
    'recentTrips': <dynamic>[],
  };

  final topupJson = {
    'id': 'p1',
    'name': 'Ali',
    'phone': '0600',
    'nfcTagId': 'tag-1',
    'balanceBefore': 100.0,
    'balanceAfter': 150.0,
    'amount': 50.0,
  };

  setUp(() {
    apiClient = MockApiClient();
    dataSource = PassengerRemoteDataSource(apiClient);
    when(() => apiClient.get(any())).thenAnswer((_) async => passengerJson);
    when(() => apiClient.post(any(), any())).thenAnswer((_) async => topupJson);
  });

  group('getByNfcTag', () {
    test('calls correct endpoint and returns map', () async {
      when(() => apiClient.get(ApiEndpoints.passengerByNfc('tag-001')))
          .thenAnswer((_) async => passengerJson);

      final result = await dataSource.getByNfcTag('tag-001');

      expect(result['_id'], 'p1');
      verify(() => apiClient.get(ApiEndpoints.passengerByNfc('tag-001')))
          .called(1);
    });
  });

  group('linkNfc', () {
    test('calls post with correct params', () async {
      when(() => apiClient.post(any(), any())).thenAnswer((_) async => {});
      const params =
          LinkNfcParams(phone: '0600', nfcTagId: 'tag-1', name: 'Ali');

      await dataSource.linkNfc(params);

      verify(() => apiClient.post(
            ApiEndpoints.linkNfc,
            any(
                that: predicate<Map<String, dynamic>>(
              (m) => m['phone'] == '0600' && m['nfcTagId'] == 'tag-1',
            )),
          )).called(1);
    });
  });

  group('recharge', () {
    test('calls post to rechargePassenger endpoint', () async {
      when(() => apiClient.post(any(), any())).thenAnswer((_) async => {});
      const params = RechargeParams(nfcTagId: 'tag-1', amount: 50);

      await dataSource.recharge(params);

      verify(() => apiClient.post(ApiEndpoints.rechargePassenger, any()))
          .called(1);
    });
  });

  group('nfcTopup', () {
    test('calls post to nfcTopup endpoint and returns NfcTopupResult',
        () async {
      when(() => apiClient.post(any(), any()))
          .thenAnswer((_) async => topupJson);
      const params = NfcTopupParams(nfcTagId: 'tag-1', amount: 50);

      final result = await dataSource.nfcTopup(params);

      expect(result.balanceBefore, 100.0);
      expect(result.balanceAfter, 150.0);
      verify(() => apiClient.post(ApiEndpoints.nfcTopup('tag-1'), any()))
          .called(1);
    });
  });

  group('phoneTopup', () {
    test('calls post to phoneTopup endpoint and returns NfcTopupResult',
        () async {
      when(() => apiClient.post(any(), any()))
          .thenAnswer((_) async => topupJson);
      const params = PhoneTopupParams(phone: '0600', amount: 50);

      final result = await dataSource.phoneTopup(params);

      expect(result.balanceBefore, 100.0);
      verify(() => apiClient.post(ApiEndpoints.phoneTopup('0600'), any()))
          .called(1);
    });
  });
}
