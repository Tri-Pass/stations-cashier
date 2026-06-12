import 'package:cashier/features/cashouts/data/datasources/cashout_remote_datasource.dart';
import 'package:cashier/features/cashouts/data/repositories/cashout_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCashoutRemoteDataSource extends Mock
    implements CashoutRemoteDataSource {}

void main() {
  late MockCashoutRemoteDataSource dataSource;
  late CashoutRepositoryImpl repo;

  setUp(() {
    dataSource = MockCashoutRemoteDataSource();
    repo = CashoutRepositoryImpl(dataSource);
    registerFallbackValue(const CashoutSummaryParams());
  });

  group('getCashoutsSummary', () {
    test('returns empty response when no cashouts', () async {
      when(() => dataSource.getCashoutsSummary(any()))
          .thenAnswer((_) async => <dynamic>[]);

      final result =
          await repo.getCashoutsSummary(const CashoutSummaryParams());

      expect(result.cashouts, isEmpty);
      expect(result.totalAmount, 0.0);
    });

    test('returns parsed cashouts from list response', () async {
      final raw = [
        {
          '_id': 'c1',
          'driver': {'_id': 'd1', 'name': 'Ahmed', 'phone': '0600'},
          'taxi': {'_id': 't1', 'plateNumber': 'ABC-123'},
          'ticketsCount': 2,
          'totalCollected': 100.0,
        }
      ];
      when(() => dataSource.getCashoutsSummary(any()))
          .thenAnswer((_) async => raw);

      final result =
          await repo.getCashoutsSummary(const CashoutSummaryParams());

      expect(result.cashouts.length, 1);
      expect(result.cashouts.first.id, 'c1');
      expect(result.cashouts.first.driver.name, 'Ahmed');
    });

    test('delegates params to datasource', () async {
      const params = CashoutSummaryParams(
        dateFrom: '2024-01-01',
        dateTo: '2024-01-31',
      );
      when(() => dataSource.getCashoutsSummary(any()))
          .thenAnswer((_) async => <dynamic>[]);

      await repo.getCashoutsSummary(params);

      verify(() => dataSource.getCashoutsSummary(params)).called(1);
    });
  });
}
