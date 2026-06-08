import 'package:cashier/features/booking/data/datasources/booking_remote_datasource.dart';
import 'package:cashier/features/booking/data/repositories/booking_repository_impl.dart';
import 'package:cashier/features/booking/domain/entities/booking_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockBookingRemoteDataSource extends Mock
    implements BookingRemoteDataSource {}

const _params = CreateBookingParams(
  taxiId: 'taxi-1',
  lineId: 'line-1',
  seatCount: 2,
  paymentMethod: 'cash',
  cashierId: 'cashier-1',
);

void main() {
  late MockBookingRemoteDataSource dataSource;
  late BookingRepositoryImpl repo;

  setUp(() {
    dataSource = MockBookingRemoteDataSource();
    repo = BookingRepositoryImpl(dataSource);
    registerFallbackValue(_params);
  });

  test('returns BookingResultEntity from parsed response', () async {
    when(() => dataSource.createBooking(any())).thenAnswer((_) async => {
          'bookingId': 'b1',
          'confirmedAt': '2024-01-01T10:00:00.000Z',
        });

    final result = await repo.createBooking(_params);

    expect(result.bookingId, 'b1');
    expect(result.confirmedAt, '2024-01-01T10:00:00.000Z');
    expect(result.ticket, isNull);
  });

  test('parses ticket in response when present', () async {
    when(() => dataSource.createBooking(any())).thenAnswer((_) async => {
          'bookingId': 'b2',
          'confirmedAt': '2024-01-01',
          'ticket': {
            'code': 'T-001',
            'seatNumber': 1,
            'origin': 'Rabat',
            'destination': 'Casa',
            'price': 50.0,
            'plateNumber': 'ABC-123',
            'driverName': 'Ahmed',
          }
        });

    final result = await repo.createBooking(_params);

    expect(result.ticket, isNotNull);
    expect(result.ticket!.code, 'T-001');
    expect(result.ticket!.origin, 'Rabat');
  });

  test('uses fallback payment method from params', () async {
    when(() => dataSource.createBooking(any())).thenAnswer((_) async => {
          'bookingId': 'b3',
          'confirmedAt': '',
          'ticket': {'code': 'T-002', 'seatNumber': 1}
        });

    final result = await repo.createBooking(_params);

    expect(result.ticket!.paymentMethod, 'cash');
  });
}
