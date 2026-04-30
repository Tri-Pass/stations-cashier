import 'package:cashier/features/booking/domain/entities/booking_entity.dart';

abstract class BookingRepository {
  Future<BookingResultEntity> createBooking(CreateBookingParams params);
}
