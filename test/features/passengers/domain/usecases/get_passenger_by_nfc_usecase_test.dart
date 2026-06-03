import 'package:cashier/features/passengers/domain/entities/passenger_entity.dart';
import 'package:cashier/features/passengers/domain/repositories/passenger_repository.dart';
import 'package:cashier/features/passengers/domain/usecases/get_passenger_by_nfc_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockPassengerRepository extends Mock implements PassengerRepository {}

void main() {
  late MockPassengerRepository repository;
  late GetPassengerByNfcUseCase useCase;

  const passenger = PassengerEntity(
    id: 'p1',
    name: 'Fatima',
    phone: '0600000001',
    balance: 150.0,
  );

  setUp(() {
    repository = MockPassengerRepository();
    useCase = GetPassengerByNfcUseCase(repository);
  });

  test('delegates to repository.getByNfcTag and returns passenger', () async {
    when(() => repository.getByNfcTag('NFC123'))
        .thenAnswer((_) async => passenger);

    final result = await useCase('NFC123');

    expect(result, equals(passenger));
    verify(() => repository.getByNfcTag('NFC123')).called(1);
  });

  test('propagates repository exception', () async {
    when(() => repository.getByNfcTag(any())).thenThrow(Exception('not found'));
    expect(() => useCase('BAD_TAG'), throwsA(isA<Exception>()));
  });
}
