import 'package:cashier/features/booking/domain/entities/booking_entity.dart';
import 'package:cashier/features/booking/domain/repositories/booking_repository.dart';
import 'package:cashier/features/booking/domain/usecases/create_booking_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockBookingRepository extends Mock implements BookingRepository {}

void main() {
  late MockBookingRepository repository;
  late CreateBookingUseCase useCase;

  const params = CreateBookingParams(
    taxiId: 't1',
    lineId: 'l1',
    seatCount: 2,
    paymentMethod: 'cash',
    cashierId: 'c1',
  );

  const result = BookingResultEntity(bookingId: 'b1', confirmedAt: '2024-01-01');

  setUpAll(() {
    registerFallbackValue(params);
  });

  setUp(() {
    repository = MockBookingRepository();
    useCase = CreateBookingUseCase(repository);
  });

  test('delegates to repository.createBooking and returns result', () async {
    when(() => repository.createBooking(any())).thenAnswer((_) async => result);

    final outcome = await useCase(params);

    expect(outcome, equals(result));
    verify(() => repository.createBooking(params)).called(1);
  });

  test('propagates repository exception', () async {
    when(() => repository.createBooking(any())).thenThrow(Exception('network error'));

    expect(() => useCase(params), throwsA(isA<Exception>()));
  });
}
