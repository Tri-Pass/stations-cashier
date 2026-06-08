import 'package:cashier/features/cashouts/data/datasources/ticket_remote_datasource.dart';
import 'package:cashier/features/cashouts/domain/entities/ticket_entity.dart';
import 'package:cashier/features/cashouts/domain/repositories/ticket_repository.dart';
import 'package:cashier/features/cashouts/domain/usecases/cashout_ticket_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockTicketRepository extends Mock implements TicketRepository {}

void main() {
  late MockTicketRepository repo;

  setUp(() {
    repo = MockTicketRepository();
    registerFallbackValue(const CashoutTicketParams(driverId: 'd1'));
  });

  test('delegates to repository.cashoutTicket and returns result', () async {
    const params = CashoutTicketParams(driverId: 'd1', ticketId: 'tk1');
    const entity = CashoutResultEntity(50.0);
    when(() => repo.cashoutTicket(any())).thenAnswer((_) async => entity);

    final result = await CashoutTicketUseCase(repo).call(params);

    expect(result.totalAmountCashedOut, 50.0);
    verify(() => repo.cashoutTicket(params)).called(1);
  });

  test('delegates cashout all to repository', () async {
    const params = CashoutTicketParams(driverId: 'd1', all: true);
    const entity = CashoutResultEntity(150.0);
    when(() => repo.cashoutTicket(any())).thenAnswer((_) async => entity);

    final result = await CashoutTicketUseCase(repo).call(params);

    expect(result.totalAmountCashedOut, 150.0);
  });
}
