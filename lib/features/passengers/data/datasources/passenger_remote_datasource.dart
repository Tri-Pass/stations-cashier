import 'package:cashier/core/constants/api_endpoints.dart';
import 'package:cashier/core/network/api_client.dart';
import 'package:cashier/features/passengers/domain/entities/passenger_entity.dart';

class PassengerRemoteDataSource {
  final ApiClient _client;
  PassengerRemoteDataSource(this._client);

  Future<Map<String, dynamic>> getByNfcTag(String tagId) async {
    return await _client.get(ApiEndpoints.passengerByNfc(tagId));
  }

  Future<void> linkNfc(LinkNfcParams params) async {
    await _client.post(ApiEndpoints.linkNfc, params.toJson());
  }
}
