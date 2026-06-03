import 'package:cashier/core/constants/api_endpoints.dart';
import 'package:cashier/core/network/api_client.dart';
import 'package:cashier/features/cashouts/data/datasources/ticket_remote_datasource.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient apiClient;
  late TicketRemoteDataSource dataSource;

  setUp(() {
    apiClient = MockApiClient();
    dataSource = TicketRemoteDataSource(apiClient);
    when(() => apiClient.get(any())).thenAnswer((_) async => {});
    when(() => apiClient.post(any(), any())).thenAnswer((_) async => {});
  });

  group('getDriverTickets', () {
    test('builds path with driverId only', () async {
      await dataSource
          .getDriverTickets(const GetDriverTicketsParams(driverId: 'd1'));
      final path =
          verify(() => apiClient.get(captureAny())).captured.first as String;
      expect(path, contains('driverId=d1'));
      expect(path, isNot(contains('date=')));
      expect(path, isNot(contains('status=')));
    });

    test('builds path with driverId and date', () async {
      await dataSource.getDriverTickets(
        const GetDriverTicketsParams(driverId: 'd1', date: '2024-06-01'),
      );
      final path =
          verify(() => apiClient.get(captureAny())).captured.first as String;
      expect(path, contains('driverId=d1'));
      expect(path, contains('date=2024-06-01'));
    });

    test('builds path with all params including status', () async {
      await dataSource.getDriverTickets(const GetDriverTicketsParams(
        driverId: 'd1',
        date: '2024-06-01',
        status: 'paid',
      ));
      final path =
          verify(() => apiClient.get(captureAny())).captured.first as String;
      expect(path, contains('driverId=d1'));
      expect(path, contains('date=2024-06-01'));
      expect(path, contains('status=paid'));
    });

    test('path starts with ticketsList endpoint', () async {
      await dataSource
          .getDriverTickets(const GetDriverTicketsParams(driverId: 'd1'));
      final path =
          verify(() => apiClient.get(captureAny())).captured.first as String;
      expect(path, startsWith(ApiEndpoints.ticketsList));
    });
  });

  group('cashoutTicket', () {
    test('posts to cashout endpoint with driverId and all=true', () async {
      await dataSource.cashoutTicket(
        const CashoutTicketParams(driverId: 'd1', all: true),
      );
      verify(() => apiClient.post(
            ApiEndpoints.cashout,
            any(
                that: predicate<Map<String, dynamic>>(
              (m) => m['driverId'] == 'd1' && m['all'] == true,
            )),
          )).called(1);
    });

    test('posts with specific ticketId when provided', () async {
      await dataSource.cashoutTicket(
        const CashoutTicketParams(driverId: 'd1', ticketId: 'tk1'),
      );
      verify(() => apiClient.post(
            any(),
            any(
                that: predicate<Map<String, dynamic>>(
                    (m) => m['ticketId'] == 'tk1')),
          )).called(1);
    });

    test('all defaults to false when not specified', () async {
      await dataSource.cashoutTicket(
        const CashoutTicketParams(driverId: 'd1'),
      );
      verify(() => apiClient.post(
            any(),
            any(
                that:
                    predicate<Map<String, dynamic>>((m) => m['all'] == false)),
          )).called(1);
    });
  });
}
