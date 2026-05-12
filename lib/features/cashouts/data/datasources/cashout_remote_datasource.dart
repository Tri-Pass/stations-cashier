import 'package:cashier/core/constants/api_endpoints.dart';
import 'package:cashier/core/network/api_client.dart';

class CashoutSummaryParams {
  final String? dateFrom;
  final String? dateTo;
  final String? driverName;
  final String? driverPhone;
  final String? taxi;
  final String? permitNumber;
  final String? line;
  final String? paymentMethod;

  const CashoutSummaryParams({
    this.dateFrom,
    this.dateTo,
    this.driverName,
    this.driverPhone,
    this.taxi,
    this.permitNumber,
    this.line,
    this.paymentMethod,
  });
}

class CashoutRemoteDataSource {
  final ApiClient _client;
  CashoutRemoteDataSource(this._client);

  Future<dynamic> getCashoutsSummary(CashoutSummaryParams params) {
    final parts = <String>[];
    void add(String key, String? value) {
      if (value != null && value.isNotEmpty) {
        parts.add('$key=${Uri.encodeQueryComponent(value)}');
      }
    }

    add('dateFrom', params.dateFrom);
    add('dateTo', params.dateTo);
    add('driverName', params.driverName);
    add('driverPhone', params.driverPhone);
    add('taxi', params.taxi);
    add('permitNumber', params.permitNumber);
    add('line', params.line);
    add('paymentMethod', params.paymentMethod);

    final path = parts.isEmpty
        ? ApiEndpoints.cashoutsSummary
        : '${ApiEndpoints.cashoutsSummary}?${parts.join('&')}';
    return _client.get(path);
  }
}
