import 'package:cashier/features/booking/data/models/booking_model.dart';
import 'package:cashier/features/booking/domain/entities/booking_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TicketModel', () {
    final json = {
      'code': 'TK001',
      'seatNumber': 3,
      'origin': 'Marrakech',
      'destination': 'Casablanca',
      'price': 50.0,
      'paymentMethod': 'nfc',
      'plateNumber': 'ABC-123',
      'driverName': 'Ahmed',
      'qrData': 'data:image/png;base64,abc',
    };

    test('fromJson maps all fields', () {
      final model = TicketModel.fromJson(json);
      expect(model.code, 'TK001');
      expect(model.seatNumber, 3);
      expect(model.origin, 'Marrakech');
      expect(model.destination, 'Casablanca');
      expect(model.price, 50.0);
      expect(model.paymentMethod, 'nfc');
      expect(model.plateNumber, 'ABC-123');
      expect(model.driverName, 'Ahmed');
      expect(model.qrData, 'data:image/png;base64,abc');
    });

    test('fromJson uses fallbackPayment when paymentMethod absent', () {
      final j = Map<String, dynamic>.from(json)..remove('paymentMethod');
      final model = TicketModel.fromJson(j, fallbackPayment: 'cash');
      expect(model.paymentMethod, 'cash');
    });

    test('fromJson defaults to empty strings and 1 for missing fields', () {
      final model = TicketModel.fromJson({});
      expect(model.code, '');
      expect(model.seatNumber, 1);
      expect(model.price, 0.0);
      expect(model.qrData, isNull);
    });

    test('toEntity produces TicketEntity', () {
      final entity = TicketModel.fromJson(json).toEntity();
      expect(entity, isA<TicketEntity>());
      expect(entity.code, 'TK001');
      expect(entity.seatNumber, 3);
    });
  });

  group('BookingResultModel', () {
    final ticketJson = {
      'code': 'TK001',
      'seatNumber': 2,
      'origin': 'Fes',
      'destination': 'Rabat',
      'price': 35.0,
      'paymentMethod': 'cash',
      'plateNumber': 'XYZ-999',
      'driverName': 'Karim',
    };

    test('fromJson with ticket maps all fields', () {
      final json = {
        'bookingId': 'b1',
        'confirmedAt': '2024-01-01T10:00:00Z',
        'passengerBalanceAfter': 200.5,
        'ticket': ticketJson,
      };
      final model = BookingResultModel.fromJson(json);
      expect(model.bookingId, 'b1');
      expect(model.confirmedAt, '2024-01-01T10:00:00Z');
      expect(model.passengerBalanceAfter, 200.5);
      expect(model.ticket, isNotNull);
      expect(model.ticket!.code, 'TK001');
    });

    test('fromJson maps _id as bookingId', () {
      final json = {'_id': 'b2', 'confirmedAt': ''};
      final model = BookingResultModel.fromJson(json);
      expect(model.bookingId, 'b2');
    });

    test('fromJson without ticket sets ticket to null', () {
      final json = {'bookingId': 'b3', 'confirmedAt': ''};
      final model = BookingResultModel.fromJson(json);
      expect(model.ticket, isNull);
    });

    test('fromJson without passengerBalanceAfter sets it to null', () {
      final json = {'bookingId': 'b4', 'confirmedAt': ''};
      final model = BookingResultModel.fromJson(json);
      expect(model.passengerBalanceAfter, isNull);
    });

    test('toEntity converts to BookingResultEntity', () {
      final json = {'bookingId': 'b5', 'confirmedAt': '2024-01-01', 'ticket': ticketJson};
      final entity = BookingResultModel.fromJson(json).toEntity();
      expect(entity, isA<BookingResultEntity>());
      expect(entity.bookingId, 'b5');
      expect(entity.ticket, isNotNull);
    });
  });

  group('CreateBookingParams', () {
    test('toJson includes all required fields', () {
      const params = CreateBookingParams(
        taxiId: 't1',
        lineId: 'l1',
        seatCount: 2,
        paymentMethod: 'cash',
        cashierId: 'c1',
      );
      final json = params.toJson();
      expect(json['taxiId'], 't1');
      expect(json['lineId'], 'l1');
      expect(json['seatCount'], 2);
      expect(json['paymentMethod'], 'cash');
      expect(json['cashierId'], 'c1');
      expect(json.containsKey('nfcTagId'), isFalse);
    });

    test('toJson includes nfcTagId when provided', () {
      const params = CreateBookingParams(
        taxiId: 't1',
        lineId: 'l1',
        seatCount: 1,
        paymentMethod: 'nfc',
        cashierId: 'c1',
        nfcTagId: 'NFC123',
      );
      expect(params.toJson()['nfcTagId'], 'NFC123');
    });
  });

  group('TicketEntity.copyWith', () {
    const ticket = TicketEntity(
      code: 'T1',
      seatNumber: 1,
      origin: 'A',
      destination: 'B',
      price: 10.0,
      paymentMethod: 'cash',
      plateNumber: 'P1',
      driverName: 'D1',
    );

    test('copyWith updates seatNumber', () {
      final copy = ticket.copyWith(seatNumber: 5);
      expect(copy.seatNumber, 5);
      expect(copy.code, 'T1');
      expect(copy.origin, 'A');
    });

    test('copyWith without args preserves all fields', () {
      final copy = ticket.copyWith();
      expect(copy.seatNumber, 1);
    });
  });
}
