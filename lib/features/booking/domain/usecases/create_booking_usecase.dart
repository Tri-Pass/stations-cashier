import 'package:cashier/features/booking/domain/entities/booking_entity.dart';
import 'package:cashier/features/booking/domain/repositories/booking_repository.dart';

class CreateBookingUseCase {
  final BookingRepository _repository;
  CreateBookingUseCase(this._repository);

  Future<BookingResultEntity> call(CreateBookingParams params) =>
      _repository.createBooking(params);
}
