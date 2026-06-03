import 'package:cashier/features/cashouts/data/datasources/ticket_remote_datasource.dart';
import 'package:cashier/features/cashouts/data/models/ticket_model.dart';
import 'package:cashier/features/cashouts/domain/entities/ticket_entity.dart';
import 'package:cashier/features/cashouts/domain/repositories/ticket_repository.dart';

class TicketRepositoryImpl implements TicketRepository {
  final TicketRemoteDataSource _ds;
  TicketRepositoryImpl(this._ds);

  @override
  Future<DriverTicketsEntity> getDriverTickets(
      GetDriverTicketsParams params) async {
    final json = await _ds.getDriverTickets(params);
    return DriverTicketsModel.fromJson(json).toEntity();
  }

  @override
  Future<CashoutResultEntity> cashoutTicket(CashoutTicketParams params) async {
    final json = await _ds.cashoutTicket(params) as Map<String, dynamic>;
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final total = ((data['totalAmountCashedOut'] ?? 0) as num).toDouble();
    return CashoutResultEntity(total);
  }
}
