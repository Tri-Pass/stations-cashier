import 'package:cashier/core/constants/api_endpoints.dart';
import 'package:cashier/core/network/api_client.dart';
import 'package:cashier/features/booking/domain/entities/booking_entity.dart';

class BookingRemoteDataSource {
  final ApiClient _client;
  BookingRemoteDataSource(this._client);

  Future<Map<String, dynamic>> createBooking(CreateBookingParams params) async {
    return await _client.post(ApiEndpoints.bookings, params.toJson());
  }
}
