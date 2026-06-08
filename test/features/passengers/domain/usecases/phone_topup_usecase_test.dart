import 'package:cashier/features/passengers/domain/entities/passenger_entity.dart';
import 'package:cashier/features/passengers/domain/repositories/passenger_repository.dart';
import 'package:cashier/features/passengers/domain/usecases/phone_topup_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockPassengerRepository extends Mock implements PassengerRepository {}

const _result = NfcTopupResult(
  id: 'p1',
  name: 'Ali',
  phone: '0600',
  nfcTagId: 'tag-1',
  balanceBefore: 200,
  balanceAfter: 300,
  amount: 100,
);

void main() {
  late MockPassengerRepository repo;

  setUp(() {
    repo = MockPassengerRepository();
    registerFallbackValue(
        const PhoneTopupParams(phone: '0600', amount: 100));
  });

  test('delegates to repository.phoneTopup and returns result', () async {
    const params = PhoneTopupParams(phone: '0600', amount: 100);
    when(() => repo.phoneTopup(any())).thenAnswer((_) async => _result);

    final result = await PhoneTopupUseCase(repo).call(params);

    expect(result, _result);
    verify(() => repo.phoneTopup(params)).called(1);
  });
}
