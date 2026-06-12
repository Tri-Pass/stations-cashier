import 'package:cashier/features/cashouts/data/datasources/ticket_remote_datasource.dart';
import 'package:cashier/features/cashouts/data/repositories/ticket_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockTicketRemoteDataSource extends Mock
    implements TicketRemoteDataSource {}

void main() {
  late MockTicketRemoteDataSource dataSource;
  late TicketRepositoryImpl repo;

  setUp(() {
    dataSource = MockTicketRemoteDataSource();
    repo = TicketRepositoryImpl(dataSource);
    registerFallbackValue(const GetDriverTicketsParams(driverId: 'd1'));
    registerFallbackValue(const CashoutTicketParams(driverId: 'd1'));
  });

  group('getDriverTickets', () {
    test('returns empty driver tickets entity', () async {
      when(() => dataSource.getDriverTickets(any())).thenAnswer((_) async => {
            'driver': {'_id': 'd1', 'name': 'Ahmed', 'phone': '0600'},
            'tickets': [],
            'summary': {
              'totalTickets': 0,
              'totalCashAmount': 0.0,
              'totalNfcAmount': 0.0,
              'totalAmount': 0.0,
            },
          });

      const params = GetDriverTicketsParams(driverId: 'd1');
      final result = await repo.getDriverTickets(params);

      expect(result.driver.name, 'Ahmed');
      expect(result.tickets, isEmpty);
      expect(result.summary.totalTickets, 0);
    });

    test('parses tickets correctly', () async {
      when(() => dataSource.getDriverTickets(any())).thenAnswer((_) async => {
            'driver': {'_id': 'd1', 'name': 'Hassan', 'phone': '0601'},
            'tickets': [
              {
                '_id': 'tk1',
                'line': {
                  '_id': 'l1',
                  'origin': 'Rabat',
                  'destination': 'Casa',
                  'price': 50.0
                },
                'totalSeats': 2,
                'paidMethod': 'cash',
                'amount': 100.0,
                'status': 'unpaid',
              }
            ],
            'summary': {
              'totalTickets': 1,
              'totalCashAmount': 100.0,
              'totalNfcAmount': 0.0,
              'totalAmount': 100.0,
            },
          });

      final result = await repo
          .getDriverTickets(const GetDriverTicketsParams(driverId: 'd1'));

      expect(result.tickets.length, 1);
      expect(result.tickets.first.id, 'tk1');
      expect(result.tickets.first.isUnpaid, isTrue);
    });
  });

  group('cashoutTicket', () {
    test('returns CashoutResultEntity with totalAmountCashedOut', () async {
      when(() => dataSource.cashoutTicket(any())).thenAnswer((_) async => {
            'data': <String, dynamic>{'totalAmountCashedOut': 50.0}
          });

      final result = await repo.cashoutTicket(
          const CashoutTicketParams(driverId: 'd1', ticketId: 'tk1'));

      expect(result.totalAmountCashedOut, 50.0);
    });

    test('returns 0 when totalAmountCashedOut missing', () async {
      when(() => dataSource.cashoutTicket(any()))
          .thenAnswer((_) async => {'data': <String, dynamic>{}});

      final result = await repo
          .cashoutTicket(const CashoutTicketParams(driverId: 'd1', all: true));

      expect(result.totalAmountCashedOut, 0.0);
    });

    test('returns 0 when data field missing', () async {
      when(() => dataSource.cashoutTicket(any()))
          .thenAnswer((_) async => <String, dynamic>{});

      final result =
          await repo.cashoutTicket(const CashoutTicketParams(driverId: 'd1'));

      expect(result.totalAmountCashedOut, 0.0);
    });
  });
}
