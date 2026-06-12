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

    test('defaults to zero for totalPaid and remaining', () {
      const e = CashoutSummaryEntity(
        id: 'c3',
        driver: CashoutDriverEntity(id: 'd1', name: 'Ali', phone: '0600'),
        taxi: CashoutTaxiEntity(id: 't1', plateNumber: 'A-001'),
        line: CashoutLineEntity(
            id: 'l1', origin: 'A', destination: 'B', price: 50),
        totalSeats: 4,
        totalAmount: 200,
      );
      expect(e.totalPaid, 0.0);
      expect(e.remaining, 0.0);
    });

    test('stores totalPaid and remaining', () {
      const e = CashoutSummaryEntity(
        id: 'c4',
        driver: CashoutDriverEntity(id: 'd2', name: 'Omar', phone: '0611'),
        taxi: CashoutTaxiEntity(id: 't2', plateNumber: 'B-002'),
        line: CashoutLineEntity(
            id: 'l2', origin: 'X', destination: 'Y', price: 80),
        totalSeats: 5,
        totalAmount: 400,
        totalPaid: 226,
        remaining: 174,
      );
      expect(e.totalPaid, 226.0);
      expect(e.remaining, 174.0);
    });
  });

  group('CashoutStatsEntity', () {
    test('stores all stats fields', () {
      const s = CashoutStatsEntity(
        totalTickets: 32,
        totalCollected: 472,
        totalNfc: 0,
        totalCash: 472,
        totalPayouts: 226,
        totalRemaining: 246,
      );
      expect(s.totalTickets, 32);
      expect(s.totalCollected, 472.0);
      expect(s.totalNfc, 0.0);
      expect(s.totalCash, 472.0);
      expect(s.totalPayouts, 226.0);
      expect(s.totalRemaining, 246.0);
    });
  });

  group('CashoutsResponseEntity', () {
    test('holds list and total', () {
      const r = CashoutsResponseEntity(cashouts: [], totalAmount: 0);
      expect(r.cashouts, isEmpty);
      expect(r.totalAmount, 0);
    });

    test('holds stats', () {
      const stats = CashoutStatsEntity(
        totalTickets: 10,
        totalCollected: 100,
        totalNfc: 0,
        totalCash: 100,
        totalPayouts: 50,
        totalRemaining: 50,
      );
      const r =
          CashoutsResponseEntity(cashouts: [], totalAmount: 100, stats: stats);
      expect(r.stats, isNotNull);
      expect(r.stats!.totalTickets, 10);
    });

    test('stats is null by default', () {
      const r = CashoutsResponseEntity(cashouts: [], totalAmount: 0);
      expect(r.stats, isNull);
    });
  });
}
