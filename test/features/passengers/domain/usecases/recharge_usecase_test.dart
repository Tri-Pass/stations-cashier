import 'package:cashier/features/passengers/domain/entities/passenger_entity.dart';
import 'package:cashier/features/passengers/domain/repositories/passenger_repository.dart';
import 'package:cashier/features/passengers/domain/usecases/recharge_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockPassengerRepository extends Mock implements PassengerRepository {}

void main() {
  late MockPassengerRepository repo;

  setUp(() {
    repo = MockPassengerRepository();
    registerFallbackValue(const RechargeParams(nfcTagId: 'tag-1', amount: 50));
  });

  test('delegates to repository.recharge with nfcTagId', () async {
    const params = RechargeParams(nfcTagId: 'tag-1', amount: 50);
    when(() => repo.recharge(any())).thenAnswer((_) async {});

    await RechargeUseCase(repo).call(params);

    verify(() => repo.recharge(params)).called(1);
  });

  test('delegates to repository.recharge with phone', () async {
    const params = RechargeParams(phone: '0600', amount: 100);
    when(() => repo.recharge(any())).thenAnswer((_) async {});

    await RechargeUseCase(repo).call(params);

    verify(() => repo.recharge(params)).called(1);
  });
}
