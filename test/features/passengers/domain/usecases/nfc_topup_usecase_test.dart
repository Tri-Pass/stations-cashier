import 'package:cashier/features/passengers/domain/entities/passenger_entity.dart';
import 'package:cashier/features/passengers/domain/repositories/passenger_repository.dart';
import 'package:cashier/features/passengers/domain/usecases/nfc_topup_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockPassengerRepository extends Mock implements PassengerRepository {}

const _result = NfcTopupResult(
  id: 'p1',
  name: 'Ali',
  phone: '0600',
  nfcTagId: 'tag-1',
  balanceBefore: 100,
  balanceAfter: 150,
  amount: 50,
);

void main() {
  late MockPassengerRepository repo;

  setUp(() {
    repo = MockPassengerRepository();
    registerFallbackValue(const NfcTopupParams(nfcTagId: 'tag-1', amount: 50));
  });

  test('delegates to repository.nfcTopup and returns result', () async {
    const params = NfcTopupParams(nfcTagId: 'tag-1', amount: 50);
    when(() => repo.nfcTopup(any())).thenAnswer((_) async => _result);

    final result = await NfcTopupUseCase(repo).call(params);

    expect(result, _result);
    verify(() => repo.nfcTopup(params)).called(1);
  });
}
