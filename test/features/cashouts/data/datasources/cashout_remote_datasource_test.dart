import 'package:cashier/core/constants/api_endpoints.dart';
import 'package:cashier/core/network/api_client.dart';
import 'package:cashier/features/cashouts/data/datasources/cashout_remote_datasource.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient apiClient;
  late CashoutRemoteDataSource dataSource;

  setUp(() {
    apiClient = MockApiClient();
    dataSource = CashoutRemoteDataSource(apiClient);
    when(() => apiClient.get(any())).thenAnswer((_) async => []);
  });

  group('getCashoutsSummary', () {
    test('calls base path when no params provided', () async {
      await dataSource.getCashoutsSummary(const CashoutSummaryParams());
      verify(() => apiClient.get(ApiEndpoints.cashoutsSummary)).called(1);
    });

    test('appends dateFrom when provided', () async {
      await dataSource.getCashoutsSummary(
        const CashoutSummaryParams(dateFrom: '2024-01-01'),
      );
      final path =
          verify(() => apiClient.get(captureAny())).captured.first as String;
      expect(path, contains('dateFrom=2024-01-01'));
    });

    test('appends dateTo when provided', () async {
      await dataSource.getCashoutsSummary(
        const CashoutSummaryParams(dateTo: '2024-01-31'),
      );
      final path =
          verify(() => apiClient.get(captureAny())).captured.first as String;
      expect(path, contains('dateTo=2024-01-31'));
    });

    test('appends driverName when provided', () async {
      await dataSource.getCashoutsSummary(
        const CashoutSummaryParams(driverName: 'Ahmed'),
      );
      final path =
          verify(() => apiClient.get(captureAny())).captured.first as String;
      expect(path, contains('driverName=Ahmed'));
    });

    test('appends all non-null params into query string', () async {
      await dataSource.getCashoutsSummary(const CashoutSummaryParams(
        dateFrom: '2024-01-01',
        dateTo: '2024-01-31',
        driverName: 'Ahmed',
        driverPhone: '0600',
        taxi: 'T1',
        line: 'l1',
        paymentMethod: 'cash',
      ));
      final path =
          verify(() => apiClient.get(captureAny())).captured.first as String;
      expect(path, contains('dateFrom='));
      expect(path, contains('dateTo='));
      expect(path, contains('driverName='));
      expect(path, contains('driverPhone='));
      expect(path, contains('taxi='));
      expect(path, contains('line='));
      expect(path, contains('paymentMethod='));
    });

    test('omits empty-string params from query string', () async {
      await dataSource.getCashoutsSummary(
        const CashoutSummaryParams(dateFrom: '2024-01-01', driverName: ''),
      );
      final path =
          verify(() => apiClient.get(captureAny())).captured.first as String;
      expect(path, contains('dateFrom='));
      expect(path, isNot(contains('driverName=')));
    });

    test('URL-encodes param values with special characters', () async {
      await dataSource.getCashoutsSummary(
        const CashoutSummaryParams(driverName: 'محمد علي'),
      );
      final path =
          verify(() => apiClient.get(captureAny())).captured.first as String;
      expect(path, contains('driverName='));
      expect(path, isNot(contains(' ')));
    });
  });
}
