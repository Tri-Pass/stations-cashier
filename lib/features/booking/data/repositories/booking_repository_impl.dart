import 'package:cashier/features/booking/data/datasources/booking_remote_datasource.dart';
import 'package:cashier/features/booking/data/models/booking_model.dart';
import 'package:cashier/features/booking/domain/entities/booking_entity.dart';
import 'package:cashier/features/booking/domain/repositories/booking_repository.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource _dataSource;
  BookingRepositoryImpl(this._dataSource);

  @override
  Future<BookingResultEntity> createBooking(CreateBookingParams params) async {
    final data = await _dataSource.createBooking(params);
    return BookingResultModel.fromJson(data,
            fallbackPayment: params.paymentMethod)
        .toEntity();
  }
}
