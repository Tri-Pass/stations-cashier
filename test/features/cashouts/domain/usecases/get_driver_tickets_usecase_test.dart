import 'package:cashier/features/cashouts/data/datasources/ticket_remote_datasource.dart';
import 'package:cashier/features/cashouts/domain/entities/ticket_entity.dart';
import 'package:cashier/features/cashouts/domain/repositories/ticket_repository.dart';
import 'package:cashier/features/cashouts/domain/usecases/get_driver_tickets_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockTicketRepository extends Mock implements TicketRepository {}

void main() {
  late MockTicketRepository repository;
  late GetDriverTicketsUseCase useCase;

  const params = GetDriverTicketsParams(driverId: 'd1');

  const driverInfo = DriverInfoEntity(id: 'd1', name: 'Ahmed', phone: '0600');
  const summary = TicketsSummaryEntity(
    totalTickets: 0,
    totalCashAmount: 0,
    totalNfcAmount: 0,
    totalAmount: 0,
  );
  const response = DriverTicketsEntity(driver: driverInfo, tickets: [], summary: summary);

  setUpAll(() {
    registerFallbackValue(params);
  });

  setUp(() {
    repository = MockTicketRepository();
    useCase = GetDriverTicketsUseCase(repository);
  });

  test('delegates to repository.getDriverTickets', () async {
    when(() => repository.getDriverTickets(any())).thenAnswer((_) async => response);

    final result = await useCase(params);

    expect(result, equals(response));
    verify(() => repository.getDriverTickets(params)).called(1);
  });

  test('propagates repository exception', () async {
    when(() => repository.getDriverTickets(any())).thenThrow(Exception('error'));
    expect(() => useCase(params), throwsA(isA<Exception>()));
  });
}
