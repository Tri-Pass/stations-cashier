import 'package:cashier/features/cashouts/domain/entities/ticket_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const line = TicketLineEntity(
    id: 'l1',
    origin: 'Fes',
    destination: 'Rabat',
    price: 35.0,
  );

  const ticket = TicketEntity(
    id: 'tk1',
    line: line,
    totalSeats: 2,
    paidMethod: 'cash',
    amount: 70.0,
    status: 'paid',
  );

  group('TicketEntity.copyWith', () {
    test('preserves original status when no arg passed', () {
      final copy = ticket.copyWith();
      expect(copy.status, 'paid');
    });

    test('updates status when new value provided', () {
      final copy = ticket.copyWith(status: 'unpaid');
      expect(copy.status, 'unpaid');
      expect(copy.id, 'tk1');
      expect(copy.paidMethod, 'cash');
    });
  });

  group('CashoutResultEntity', () {
    test('stores totalAmountCashedOut', () {
      const result = CashoutResultEntity(250.0);
      expect(result.totalAmountCashedOut, 250.0);
    });

    test('stores zero amount', () {
      const result = CashoutResultEntity(0.0);
      expect(result.totalAmountCashedOut, 0.0);
    });
  });

  group('TicketsSummaryEntity', () {
    test('stores all summary values', () {
      const summary = TicketsSummaryEntity(
        totalTickets: 5,
        totalCashAmount: 200.0,
        totalNfcAmount: 100.0,
        totalAmount: 300.0,
      );
      expect(summary.totalTickets, 5);
      expect(summary.totalCashAmount, 200.0);
      expect(summary.totalNfcAmount, 100.0);
      expect(summary.totalAmount, 300.0);
    });
  });
}
