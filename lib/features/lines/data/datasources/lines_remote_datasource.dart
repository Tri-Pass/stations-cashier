import 'package:cashier/core/config/api_config.dart';
import 'package:cashier/core/network/api_client.dart';

class LinesRemoteDataSource {
  final ApiClient _client;
  LinesRemoteDataSource(this._client);

  Future<List<dynamic>> getLines(String stationId) async {
    final data = await _client.get(ApiConfig.lines(stationId));
    return data as List<dynamic>;
  }

  Future<List<dynamic>> getLineQueue(String stationId, String lineId) async {
    final data = await _client.get(ApiConfig.lineQueue(stationId, lineId));
    return data as List<dynamic>;
  }
}
