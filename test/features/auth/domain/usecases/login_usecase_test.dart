import 'package:cashier/features/auth/domain/entities/driver_entity.dart';
import 'package:cashier/features/auth/domain/repositories/auth_repository.dart';
import 'package:cashier/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;
  late LoginUseCase useCase;

  const driver = DriverEntity(
    id: 'd1',
    name: 'Ahmed',
    phone: '0600000001',
    taxiNumber: 'T1',
    plateNumber: 'P1',
    balance: 100.0,
  );

  setUp(() {
    repository = MockAuthRepository();
    useCase = LoginUseCase(repository);
  });

  test('delegates to repository.login and returns driver', () async {
    when(() => repository.login('0600000001', 'pass123'))
        .thenAnswer((_) async => driver);

    final result = await useCase('0600000001', 'pass123');

    expect(result, equals(driver));
    verify(() => repository.login('0600000001', 'pass123')).called(1);
  });

  test('propagates exception from repository', () async {
    when(() => repository.login(any(), any()))
        .thenThrow(Exception('server error'));

    expect(() => useCase('0600', 'bad'), throwsA(isA<Exception>()));
  });
}
