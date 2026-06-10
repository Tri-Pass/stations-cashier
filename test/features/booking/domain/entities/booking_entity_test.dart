import 'package:cashier/features/booking/domain/entities/booking_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CreateBookingParams', () {
    test('toJson includes all required fields', () {
      const p = CreateBookingParams(
        taxiId: 't1',
        lineId: 'l1',
        seatCount: 2,
        paymentMethod: 'cash',
        cashierId: 'c1',
      );
      final json = p.toJson();
      expect(json['taxiId'], 't1');
      expect(json['lineId'], 'l1');
      expect(json['seatCount'], 2);
      expect(json['paymentMethod'], 'cash');
      expect(json['cashierId'], 'c1');
      expect(json.containsKey('nfcTagId'), isFalse);
    });

    test('toJson includes nfcTagId when provided', () {
      const p = CreateBookingParams(
        taxiId: 't1',
        lineId: 'l1',
        seatCount: 1,
        paymentMethod: 'nfc',
        cashierId: 'c1',
        nfcTagId: 'tag-abc',
      );
      expect(p.toJson()['nfcTagId'], 'tag-abc');
    });
  });

  group('TicketEntity', () {
    const ticket = TicketEntity(
      code: 'TK-001',
      seatNumber: 3,
      origin: 'Marrakech',
      destination: 'Casablanca',
      price: 80.0,
      paymentMethod: 'cash',
      plateNumber: 'A-001-MA',
      driverName: 'Ahmed',
    );

    test('copyWith overrides seatNumber', () {
      final copy = ticket.copyWith(seatNumber: 5);
      expect(copy.seatNumber, 5);
      expect(copy.code, ticket.code);
      expect(copy.origin, ticket.origin);
    });

    test('copyWith without args returns equivalent object', () {
      final copy = ticket.copyWith();
      expect(copy.seatNumber, ticket.seatNumber);
    });
  });

  group('BookingResultEntity', () {
    test('ticket is optional', () {
      const r = BookingResultEntity(bookingId: 'b1', confirmedAt: '2026-01-01');
      expect(r.ticket, isNull);
      expect(r.passengerBalanceAfter, isNull);
    });

    test('holds all fields', () {
      const r = BookingResultEntity(
        bookingId: 'b1',
        confirmedAt: '2026-01-01T10:00:00',
        passengerBalanceAfter: 150.0,
      );
      expect(r.bookingId, 'b1');
      expect(r.passengerBalanceAfter, 150.0);
    });
  });
}
