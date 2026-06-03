import 'package:cashier/features/cashouts/data/datasources/cashout_remote_datasource.dart';
import 'package:cashier/features/cashouts/domain/entities/cashout_summary_entity.dart';
import 'package:cashier/features/cashouts/domain/repositories/cashout_repository.dart';
import 'package:cashier/features/cashouts/domain/usecases/get_cashouts_summary_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCashoutRepository extends Mock implements CashoutRepository {}

void main() {
  late MockCashoutRepository repository;
  late GetCashoutsSummaryUseCase useCase;

  const params = CashoutSummaryParams();

  const response = CashoutsResponseEntity(cashouts: [], totalAmount: 0.0);

  setUpAll(() {
    registerFallbackValue(params);
  });

  setUp(() {
    repository = MockCashoutRepository();
    useCase = GetCashoutsSummaryUseCase(repository);
  });

  test('delegates to repository.getCashoutsSummary', () async {
    when(() => repository.getCashoutsSummary(any())).thenAnswer((_) async => response);

    final result = await useCase(params);

    expect(result, equals(response));
    verify(() => repository.getCashoutsSummary(params)).called(1);
  });

  test('propagates repository exception', () async {
    when(() => repository.getCashoutsSummary(any())).thenThrow(Exception('error'));
    expect(() => useCase(params), throwsA(isA<Exception>()));
  });
}
