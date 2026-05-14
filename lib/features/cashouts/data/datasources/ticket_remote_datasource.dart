import 'package:cashier/core/constants/api_endpoints.dart';
import 'package:cashier/core/network/api_client.dart';

class GetDriverTicketsParams {
  final String driverId;
  final String? date;
  final String? status;
  const GetDriverTicketsParams({required this.driverId, this.date, this.status});
}

class CashoutTicketParams {
  final String driverId;
  final String? ticketId;
  final bool all;
  const CashoutTicketParams({
    required this.driverId,
    this.ticketId,
    this.all = false,
  });
}

class TicketRemoteDataSource {
  final ApiClient _client;
  TicketRemoteDataSource(this._client);

  Future<dynamic> getDriverTickets(GetDriverTicketsParams params) async {
    final parts = ['driverId=${Uri.encodeQueryComponent(params.driverId)}'];
    if (params.date != null) parts.add('date=${params.date}');
    if (params.status != null) parts.add('status=${params.status}');
    return _client.get('${ApiEndpoints.ticketsList}?${parts.join('&')}');
  }

  Future<dynamic> cashoutTicket(CashoutTicketParams params) async {
    return _client.post(ApiEndpoints.cashout, {
      'driverId': params.driverId,
      'ticketId': params.ticketId,
      'all': params.all,
    });
  }
}
