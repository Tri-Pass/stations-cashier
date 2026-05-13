import 'package:cashier/features/cashouts/data/datasources/ticket_remote_datasource.dart';
import 'package:cashier/features/cashouts/domain/entities/ticket_entity.dart';
import 'package:cashier/features/cashouts/domain/repositories/ticket_repository.dart';

class CashoutTicketUseCase {
  final TicketRepository _repo;
  CashoutTicketUseCase(this._repo);

  Future<CashoutResultEntity> call(CashoutTicketParams params) =>
      _repo.cashoutTicket(params);
}
