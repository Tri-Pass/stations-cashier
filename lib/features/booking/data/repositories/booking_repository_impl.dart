import 'package:cashier/features/booking/data/datasources/booking_remote_datasource.dart';
import 'package:cashier/features/booking/domain/entities/booking_entity.dart';
import 'package:cashier/features/booking/domain/repositories/booking_repository.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource _dataSource;
  BookingRepositoryImpl(this._dataSource);

  @override
  Future<BookingResultEntity> createBooking(CreateBookingParams params) async {
    final d = await _dataSource.createBooking(params);
    return BookingResultEntity(
      id: (d['_id'] ?? d['id'] ?? '') as String,
      seatCount: (d['seatCount'] ?? params.seatCount) as int,
      amount: ((d['amount'] ?? 0) as num).toDouble(),
      paymentMethod: (d['paymentMethod'] ?? params.paymentMethod) as String,
    );
  }
}
