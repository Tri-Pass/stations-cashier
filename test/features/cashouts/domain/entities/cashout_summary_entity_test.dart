import 'package:cashier/features/cashouts/domain/entities/cashout_summary_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CashoutSummaryEntity', () {
    test('defaults to zero for breakdown fields', () {
      const e = CashoutSummaryEntity(
        id: 'c1',
        driver: CashoutDriverEntity(id: 'd1', name: 'Ali', phone: '0600'),
        taxi: CashoutTaxiEntity(id: 't1', plateNumber: 'A-001'),
        line: CashoutLineEntity(
            id: 'l1', origin: 'A', destination: 'B', price: 50),
        totalSeats: 4,
        totalAmount: 200,
      );
      expect(e.cashSeats, 0);
      expect(e.nfcSeats, 0);
      expect(e.cashAmount, 0);
      expect(e.nfcAmount, 0);
      expect(e.departedAt, isNull);
    });

    test('stores payment breakdown', () {
      const e = CashoutSummaryEntity(
        id: 'c2',
        driver: CashoutDriverEntity(id: 'd2', name: 'Youssef', phone: '0611'),
        taxi: CashoutTaxiEntity(id: 't2', plateNumber: 'B-002'),
        line: CashoutLineEntity(
            id: 'l2', origin: 'X', destination: 'Y', price: 80),
        totalSeats: 6,
        totalAmount: 480,
        cashSeats: 4,
        nfcSeats: 2,
        cashAmount: 320,
        nfcAmount: 160,
      );
      expect(e.cashSeats, 4);
      expect(e.nfcAmount, 160);
    });
  });

  group('CashoutsResponseEntity', () {
    test('holds list and total', () {
      const r = CashoutsResponseEntity(cashouts: [], totalAmount: 0);
      expect(r.cashouts, isEmpty);
      expect(r.totalAmount, 0);
    });
  });
}
