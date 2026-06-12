import 'package:cashier/core/constants/api_endpoints.dart';
import 'package:cashier/core/network/api_client.dart';
import 'package:cashier/features/booking/data/datasources/booking_remote_datasource.dart';
import 'package:cashier/features/booking/domain/entities/booking_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockApiClient extends Mock implements ApiClient {}

const _params = CreateBookingParams(
  taxiId: 'taxi-1',
  lineId: 'line-1',
  seatCount: 2,
  paymentMethod: 'cash',
  cashierId: 'cashier-1',
);

void main() {
  late MockApiClient apiClient;
  late BookingRemoteDataSource dataSource;

  setUp(() {
    apiClient = MockApiClient();
    dataSource = BookingRemoteDataSource(apiClient);
    when(() => apiClient.post(any(), any()))
        .thenAnswer((_) async => <String, dynamic>{});
  });

  test('calls post to bookings endpoint', () async {
    await dataSource.createBooking(_params);

    verify(() => apiClient.post(ApiEndpoints.bookings, any())).called(1);
  });

  test('sends correct params in request body', () async {
    await dataSource.createBooking(_params);

    final captured = verify(() => apiClient.post(any(), captureAny()))
        .captured
        .first as Map<String, dynamic>;
    expect(captured['taxiId'], 'taxi-1');
    expect(captured['lineId'], 'line-1');
    expect(captured['seatCount'], 2);
    expect(captured['paymentMethod'], 'cash');
    expect(captured['cashierId'], 'cashier-1');
  });

  test('returns the raw map from api client', () async {
    final response = {'bookingId': 'b1', 'confirmedAt': '2024-01-01'};
    when(() => apiClient.post(any(), any())).thenAnswer((_) async => response);

    final result = await dataSource.createBooking(_params);

    expect(result, response);
  });
}
