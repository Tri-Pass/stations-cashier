import 'package:cashier/core/config/api_config.dart';
import 'package:cashier/core/network/api_client.dart';
import 'package:cashier/features/passengers/domain/entities/passenger_entity.dart';

class PassengerRemoteDataSource {
  final ApiClient _client;
  PassengerRemoteDataSource(this._client);

  Future<Map<String, dynamic>> getByNfcTag(String tagId) async {
    return await _client.get(ApiConfig.passengerByNfc(tagId));
  }

  Future<void> linkNfc(LinkNfcParams params) async {
    await _client.post(ApiConfig.linkNfc, params.toJson());
  }
}
