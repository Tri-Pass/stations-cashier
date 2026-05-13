import 'package:cashier/features/cashouts/data/datasources/ticket_remote_datasource.dart';
import 'package:cashier/features/cashouts/domain/entities/ticket_entity.dart';
import 'package:cashier/features/cashouts/domain/repositories/ticket_repository.dart';

class GetDriverTicketsUseCase {
  final TicketRepository _repo;
  GetDriverTicketsUseCase(this._repo);

  Future<DriverTicketsEntity> call(GetDriverTicketsParams params) =>
      _repo.getDriverTickets(params);
}
