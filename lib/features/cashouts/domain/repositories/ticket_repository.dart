import 'package:cashier/features/cashouts/data/datasources/ticket_remote_datasource.dart';
import 'package:cashier/features/cashouts/domain/entities/ticket_entity.dart';

abstract class TicketRepository {
  Future<DriverTicketsEntity> getDriverTickets(GetDriverTicketsParams params);
  Future<CashoutResultEntity> cashoutTicket(CashoutTicketParams params);
}
