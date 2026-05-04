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

  Future<void> recharge(RechargeParams params) async {
    await _client.post(ApiEndpoints.rechargePassenger, params.toJson());
  }

  Future<NfcTopupResult> nfcTopup(NfcTopupParams params) async {
    final data = await _client.post(
      ApiEndpoints.nfcTopup(params.nfcTagId),
      params.toJson(),
    );
    return NfcTopupResult.fromJson(data as Map<String, dynamic>);
  }

  Future<NfcTopupResult> phoneTopup(PhoneTopupParams params) async {
    final data = await _client.post(
      ApiEndpoints.phoneTopup(params.phone),
      params.toJson(),
    );
    return NfcTopupResult.fromJson(data as Map<String, dynamic>);
  }
}
