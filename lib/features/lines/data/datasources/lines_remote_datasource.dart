import 'package:cashier/core/constants/api_endpoints.dart';
import 'package:cashier/core/network/api_client.dart';

class LinesRemoteDataSource {
  final ApiClient _client;
  LinesRemoteDataSource(this._client);

  Future<List<dynamic>> getLines(String stationId) async {
    final data = await _client.get(ApiEndpoints.lines(stationId));
    return data as List<dynamic>;
  }

  Future<List<dynamic>> getLineQueue(String stationId, String lineId) async {
    final data = await _client.get(ApiEndpoints.lineQueue(stationId, lineId));
    return data as List<dynamic>;
  }
}
