import 'package:cashier/core/constants/api_endpoints.dart';
import 'package:cashier/core/network/api_client.dart';
import 'package:cashier/features/drivers/domain/entities/nfc_driver_info.dart';

class DriverRemoteDataSource {
  final ApiClient _client;
  DriverRemoteDataSource(this._client);

  Future<NfcDriverInfo> lookupByNfc(String tagId) async {
    final data = await _client.get(ApiEndpoints.driverByNfc(tagId));
    return NfcDriverInfo.fromJson(data as Map<String, dynamic>);
  }

  Future<void> enqueue(String driverId, String lineId) async {
    await _client
        .post(ApiEndpoints.queue, {'driverId': driverId, 'lineId': lineId});
  }
}
