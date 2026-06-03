import 'package:cashier/features/cashouts/data/models/ticket_model.dart';
import 'package:cashier/features/cashouts/domain/entities/ticket_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TicketLineModel', () {
    test('fromJson maps all fields', () {
      final m = TicketLineModel.fromJson({
        '_id': 'l1',
        'origin': 'Fes',
        'destination': 'Rabat',
        'price': 35.0,
      });
      expect(m.id, 'l1');
      expect(m.origin, 'Fes');
      expect(m.destination, 'Rabat');
      expect(m.price, 35.0);
    });

    test('toEntity maps correctly', () {
      final entity = TicketLineModel(
        id: 'l1',
        origin: 'Fes',
        destination: 'Rabat',
        price: 35.0,
      ).toEntity();
      expect(entity, isA<TicketLineEntity>());
      expect(entity.origin, 'Fes');
    });
  });

  group('TicketModel', () {
    final jsonCamel = {
      '_id': 'tk1',
      'line': {'id': 'l1', 'origin': 'A', 'destination': 'B', 'price': 10.0},
      'totalSeats': 4,
      'paidMethod': 'nfc',
      'amount': 40.0,
      'departedAt': '2024-06-01T08:00:00Z',
      'status': 'paid',
    };

    test('fromJson maps camelCase keys', () {
      final m = TicketModel.fromJson(jsonCamel);
      expect(m.id, 'tk1');
      expect(m.totalSeats, 4);
      expect(m.paidMethod, 'nfc');
      expect(m.amount, 40.0);
      expect(m.departedAt, isNotNull);
      expect(m.status, 'paid');
    });

    test('fromJson maps snake_case keys', () {
      final j = {
        '_id': 'tk2',
        'line': <String, dynamic>{},
        'total_seats': 2,
        'paid_method': 'cash',
        'amount': 20.0,
        'departed_at': '2024-06-01T09:00:00Z',
        'status': 'unpaid',
      };
      final m = TicketModel.fromJson(j);
      expect(m.totalSeats, 2);
      expect(m.paidMethod, 'cash');
      expect(m.departedAt, isNotNull);
    });

    test('fromJson defaults when fields absent', () {
      final m = TicketModel.fromJson({'line': <String, dynamic>{}});
      expect(m.id, '');
      expect(m.totalSeats, 1);
      expect(m.paidMethod, 'cash');
      expect(m.amount, 0.0);
      expect(m.departedAt, isNull);
      expect(m.status, 'unpaid');
    });

    test('toEntity produces TicketEntity', () {
      final entity = TicketModel.fromJson(jsonCamel).toEntity();
      expect(entity, isA<TicketEntity>());
      expect(entity.paidMethod, 'nfc');
    });
  });

  group('TicketEntity getters', () {
    const cashTicket = TicketEntity(
      id: 't1',
      line: TicketLineEntity(id: 'l1', origin: 'A', destination: 'B', price: 10),
      totalSeats: 1,
      paidMethod: 'cash',
      amount: 10,
      status: 'paid',
    );

    const nfcTicket = TicketEntity(
      id: 't2',
      line: TicketLineEntity(id: 'l1', origin: 'A', destination: 'B', price: 10),
      totalSeats: 1,
      paidMethod: 'nfc',
      amount: 10,
      status: 'unpaid',
    );

    test('isCash is true for cash paidMethod', () {
      expect(cashTicket.isCash, isTrue);
    });

    test('isCash is false for nfc paidMethod', () {
      expect(nfcTicket.isCash, isFalse);
    });

    test('isUnpaid is false for paid status', () {
      expect(cashTicket.isUnpaid, isFalse);
    });

    test('isUnpaid is true for unpaid status', () {
      expect(nfcTicket.isUnpaid, isTrue);
    });

    test('copyWith updates status', () {
      final copy = nfcTicket.copyWith(status: 'paid');
      expect(copy.status, 'paid');
      expect(copy.paidMethod, 'nfc');
    });
  });

  group('DriverInfoModel', () {
    test('fromJson maps all fields', () {
      final m = DriverInfoModel.fromJson({'_id': 'd1', 'name': 'Ahmed', 'phone': '0600'});
      expect(m.id, 'd1');
      expect(m.name, 'Ahmed');
    });

    test('toEntity maps correctly', () {
      final entity = DriverInfoModel(id: 'd1', name: 'Ahmed', phone: '0600').toEntity();
      expect(entity.id, 'd1');
    });
  });

  group('TicketsSummaryModel', () {
    test('fromJson maps all fields', () {
      final m = TicketsSummaryModel.fromJson({
        'totalTickets': 10,
        'totalCashAmount': 200.0,
        'totalNfcAmount': 150.0,
        'totalAmount': 350.0,
      });
      expect(m.totalTickets, 10);
      expect(m.totalCashAmount, 200.0);
      expect(m.totalNfcAmount, 150.0);
      expect(m.totalAmount, 350.0);
    });

    test('fromJson defaults to 0 when fields absent', () {
      final m = TicketsSummaryModel.fromJson({});
      expect(m.totalTickets, 0);
      expect(m.totalAmount, 0.0);
    });
  });

  group('DriverTicketsModel', () {
    final rawData = {
      'driver': {'_id': 'd1', 'name': 'Ahmed', 'phone': '0600'},
      'tickets': [
        {
          '_id': 'tk1',
          'line': {'id': 'l1', 'origin': 'Fes', 'destination': 'Rabat', 'price': 35.0},
          'totalSeats': 2,
          'paidMethod': 'cash',
          'amount': 70.0,
          'status': 'paid',
        },
      ],
      'summary': {
        'totalTickets': 1,
        'totalCashAmount': 70.0,
        'totalNfcAmount': 0.0,
        'totalAmount': 70.0,
      },
    };

    test('fromJson without data wrapper parses correctly', () {
      final model = DriverTicketsModel.fromJson(rawData);
      expect(model.driver.name, 'Ahmed');
      expect(model.tickets.length, 1);
      expect(model.summary.totalTickets, 1);
    });

    test('fromJson with data wrapper parses correctly', () {
      final model = DriverTicketsModel.fromJson({'data': rawData});
      expect(model.driver.name, 'Ahmed');
      expect(model.tickets.length, 1);
    });

    test('toEntity maps to DriverTicketsEntity', () {
      final entity = DriverTicketsModel.fromJson(rawData).toEntity();
      expect(entity.driver.name, 'Ahmed');
      expect(entity.tickets.length, 1);
      expect(entity.summary.totalAmount, 70.0);
    });
  });
}
